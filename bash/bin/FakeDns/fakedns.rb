require 'rubygems'
require 'sinatra'
require 'date'

DATAFILE = "hostdata.yml"
# Hosts data is a simple data structure, stored in a hash, of:
#  namespaces, a map of maps with structure:
#    namespace_name => { :hosts => { mac_address => { :name => name, :ip => ip_address, :time => time_updated } }
#      :errors => [list of string errors] }
# The hosts file is read and written on every request - should be safe as the server is
#  single-threaded.  Hosts file should be manually edited by hand to prune errors etc!
before do
  if File.readable?(DATAFILE)
    @datafile = YAML.load_file(DATAFILE)
  else
    @datafile = {}
  end
end

def save_data
  File.open(DATAFILE,"w") do |out|
    YAML.dump(@datafile, out)
  end
end

helpers do
  def namespace_names
    @datafile.keys.sort
  end
  
  def need_namespace(namespace)
    unless @datafile.has_key?(namespace)
      @datafile[namespace] = {:hosts => {}, :errors => []}
    end
  end
  
  def ns_hosts(namespace)
    need_namespace(namespace)
    @datafile[namespace][:hosts]
  end
  
  def ns_errors(namespace)
    need_namespace(namespace)
    @datafile[namespace][:errors]
  end
end
  
get '/' do
  erb <<-END
      <h3><a href="http://wiki.sensis.com.au/confluence/display/GEN/FakeDns">FakeDns</a> - a suite of tools for ip address sharing between pcs</h3>
      <p>See the <a href="http://wiki.sensis.com.au/confluence/display/GEN/FakeDns">FakeDns</a> wiki page for more information.</p>
      <h5>FakeDns Namespaces:</h5>
      <% namespace_names.each do |namespace| %>
      <p>Namespace: <strong><%= namespace %></strong> Generated /etc/hosts file: <a href="/hosts/<%=namespace%>">hosts</a></p>
      <% end %>
      <hr/>
      <% namespace_names.each do |namespace| 
          hosts = ns_hosts(namespace)
          errors = ns_errors(namespace)
      %>
      <p><strong>Namespace <%= namespace %></strong> hosts data (oldest first):</p>
      <ul>
       <% hosts.keys.sort_by {|key| Date.parse(hosts[key][:time])}.each do |mac|
             host = hosts[mac] %>
         <li><%=mac%> -> name=<%=host[:name]%> ip=<%=host[:ip]%> updated at <%=host[:time]%></li>
       <% end %>
      </ul>
      <hr/>
      <p><strong>Namespace <%= namespace %></strong> Errors logged:</p>
      <ul>
      <% errors.each do |line| %>
         <li><%=line%></li>
      <% end %>
      </ul>
      <hr/>
      <% end %>
      <form action='/' method="POST">
        namespace:<input type="text" name="namespace" />
        mac:<input type="text" name="mac" />
        name:<input type="text" name="name" />
        ip:<input type="text" name="ip" />
        <input type="submit" value="Submit a host" />
      </form>
  END
end

get '/hosts/:namespace' do
  headers 'Content-Type' => 'text/plain'
  namespace = params[:namespace]
  hosts = ns_hosts(namespace)
  resp = "\# Host file data for namespace #{namespace} created by fakedns.rb\n"
  hosts.keys.sort.each do |mac|
    host = hosts[mac]
    resp += "#{host[:ip]} #{host[:name]}\n"
  end
  resp
end
  
get '/url_for/:namespace' do
  @errors = []
  begin
    namespace = params[:namespace]
    hostname = params[:hostname]
    port = params[:port]
    want_redirect = params[:redirect] ? params[:redirect].strip == "true" : false
    # TODO: pass all other parameters to original url
    if !hostname || !port
      raise "you must specify a hostname and a port parameter"
    end
    hosts = ns_hosts(namespace)
    host = hosts.values.detect {|h| h[:name] == hostname}
    raise "can't find host with namespace #{namespace} and name #{hostname}" unless host
    ip = host[:ip]
    redirect_url = "http://#{ip}:#{port}"
    if want_redirect
      redirect redirect_url
    else
      body do
        <<-END
          <h3>FakeDNS url for host #{hostname} with port #{port} in namespace #{namespace}</h3>
          <p><a href="#{redirect_url}">#{redirect_url}</a></p>
          <p>(last updated at #{host[:time]})</p>
        END
      end
    end
  rescue Exception => @e
    status 500
    body do
      erb <<-END
      <p>Errors occurred:</p>
      <% if @errors.size > 0 %>
      <ul>
       <% @errors.each do |error| %>
       <li><%=error%></li>
       <% end %>
      </ul>
      <% end %>
      <p>Exceptions:</p>
      <pre>
        <%= @e.to_yaml %>
      </pre>
      END
    end
  end
end
  
post '/' do
  namespace = params[:namespace].strip
  mac = params[:mac].strip
  name = params[:name].strip
  ip = params[:ip].strip
  force = params[:force] ? params[:force].strip == "yes" : false
  hosts = ns_hosts(namespace)
  errors = ns_errors(namespace)
  @new_errors = []
  if mac.size == 0 || name.size == 0 || ip.size == 0
    errormsg = "#{Time.now}: Error adding host '#{name}' with ip '#{ip}' from mac address '#{mac}' - all parameters must be supplied"
    @new_errors << errormsg
    errors << errormsg
  end
  macs_to_delete = []
  hosts.each do |other_mac, other_host|
    if other_host[:name] == name && other_mac != mac
      if force
        msg = "#{Time.now}: removing old host '#{other_host[:name]}' with ip '#{other_host[:ip]}' and mac address '#{other_mac}'"
        puts msg
        macs_to_delete << other_mac
      else
        errormsg = "#{Time.now}: Error adding host '#{name}' with ip '#{ip}' from mac address '#{mac}' - collides with host '#{other_host[:name]}' with ip '#{other_host[:ip]}' from mac address '#{other_mac}'"
        @new_errors << errormsg
        errors << errormsg
      end
    end
  end
  if @new_errors.size == 0
    macs_to_delete.each {|deadmac| hosts.delete(deadmac)}
    hosts[mac] = {:name => name, :ip => ip, :time => Time.now.to_s}
  end
  save_data
  if @new_errors.size > 0
    status 500
    erb <<-END
      <p>Errors occurred:</p>
      <ul>
       <% @new_errors.each do |error| %>
       <li><%=error%></li>
       <% end %>
      </ul>
      <a href=\"/\">Back to FakeDNS</a>
    END
  else
    "ok - go to <a href=\"/\">main page</a> for results, or <a href=\"/hosts/#{namespace}\">/hosts/#{namespace}</a> for hosts file snippet."
  end
end
  
