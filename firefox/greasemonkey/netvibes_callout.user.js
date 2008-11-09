// ==UserScript==
// @name           netvibes callout
// @namespace      net.gfxmonk.greasemonkey.netvibes
// @description    Growl notifications for netvibes
// @include        http://www.netvibes.com/#*
// @include        http://netvibes.com/#*
// @include        http://iphone.facebook.com/#/home.php
// ==/UserScript==

/*

This greasemonkey script requires callout:
https://addons.mozilla.org/en-US/firefox/addon/7458

It currently supports the following netvibes modules:
 * twitter
 * Facebook iPhone (http://nvmodules.typhon.net/romain/facebook/iphone/)

*/

(function() {
	var last_seen_key = 'lastseen.'
	function latest_content(service) {
	
		return GM_getValue(last_seen_key + service, null)
	}

	function save_latest_content(service, val) {
		GM_setValue(last_seen_key + service, val.toString())
	}

	function notify(msg, service_name, icon_url) {
		if(service_name == null) {
			service_name = 'Callout'
		}
		var opts = null
		if(icon_url != null) { 
			opts = {icon: icon_url}
		}
		callout.notify(service_name, msg, opts)
	}

	var poll_seconds = 2 * 60
	
	function glog(service, msg) {
		GM_log('[' + service + '] ' + msg)
	}


	function process_items(service_name, items, icon_url, notify_func) {
		if(notify_func == null) {
			notify_func = notify
		}
		if(items.length > 0) {
			var item
			var last_item = items[0]
			while((item = items.pop()) != null) {
				notify_func(item, service_name, icon_url)
			}
			save_latest_content(service_name, last_item)
		}
	}

	function scan_service(service_name, module_sel, item_sel, item_content_sel, content_proc) {
		// retrns an array of unseen items; newest first
		var items_found = Array()
		var found_anything = false
		var this_latest_content = latest_content(service_name)

		var module = $(unsafeWindow.document).find(module_sel)
		glog(service_name, 'module: ' + module_sel + ' -> ' + module.length)
		
		if(module.length > 0) {
			var items = module.find(item_sel)
			glog(service_name, 'items:  ' + item_sel + ' -> ' + items.length)
		
			items.each(function(i){
				var content_nodes = $(this)
				if(item_content_sel != null) {
					content_nodes = content_nodes.find(item_content_sel)
				}
				var content = content_nodes.text()
				if(content_proc != null) {
					content = content_proc($(this), content_nodes)
				}
		
				found_anything = true
				glog(service_name, "found some content: " + content)
				if(content == this_latest_content) {
					glog(service_name, "it's old...")
					return false
				}
				// apparently, push and unshift do the same thing. but push *shouldn't*,
				// so I'm using unshift and then reversing the array later.
				items_found.unshift(content)
			})
		}
		
		if(!found_anything) {
			glog(service_name, "couldn't find anything!")
		}
		return items_found.reverse();
	}

	function scan_twitter() {
		if(!document.location.href.match(/netvibes/)) return;
		items = scan_service('twitter', '.moduleContent.twitter', '.item', 'p.description',
			function(item_node, content_nodes) {
				return content_nodes.text().replace(item_node.find('a.time').text(), '')
			}
		)
		
		process_items('twitter', items, 'http://assets0.twitter.com/images/favicon.ico',
			function(msg, service, icon){
				notify(msg.replace(/^([^ ]+)/, ''), service + ': ' + msg.split(' ')[0], icon)
			}
		)
	}
	
	function scan_facebook() {
		if(!document.location.href.match(/facebook/)) return;
		service = 'facebook'
		items = scan_service(service, 'body.ready', '.feedStory', null)
		process_items(service, items, 'http://static.ak.fbcdn.net/images/icons/favicon.gif')
	}

	function scan_all(){
		try {
			GM_log(" ---- ");
			GM_log("scanning...");
			scan_twitter()
			scan_facebook()
		} catch(e) {
			GM_log("Exception: " + e);
		}
	
		GM_log("setting timeout...")
		window.setTimeout(scan_all, 1000 * poll_seconds);
		GM_log(" ---- ");
	}

	// Add jQuery
	if(typeof unsafeWindow.jQuery == 'undefined') {
		var GM_JQ = document.createElement('script');
		GM_JQ.src = 'http://jquery.com/src/jquery-latest.js';
		GM_JQ.type = 'text/javascript';
		document.getElementsByTagName('head')[0].appendChild(GM_JQ);

		// Check if jQuery has loaded
		function GM_wait() {
			if(typeof unsafeWindow.jQuery == 'undefined') {
				window.setTimeout(GM_wait,100);
			}
			else {
				$ = unsafeWindow.jQuery
				$.noConflict()
				scan_all()
			}
		}
	}

	console.log("netvibes scanner starting up..")
	GM_wait();
})()
