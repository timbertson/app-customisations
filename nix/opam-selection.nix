### This file is generated by opam2nix.

self:
let
    lib = self.lib;
    pkgs = self.pkgs;
    repoPath = self.repoPath;
    repos = 
    {
      opam-repository = 
      rec {
        fetch = 
        {
          owner = "ocaml";
          repo = "opam-repository";
          rev = "9bfb3511644e1e962de8f4613c93ddbb14968da8";
          sha256 = "11g4kd3bssvfvgjkc7462imphy0hh27qhmzdg1i42yy8n0j3mmhg";
        };
        src = (pkgs.fetchFromGitHub) fetch;
      };
    };
    selection = self.selection;
in
{
  format-version = 4;
  ocaml-version = "4.10.0";
  repos = repos;
  selection = 
  {
    base-threads = 
    {
      opamInputs = {
      };
      opamSrc = repoPath (repos.opam-repository.src) 
      {
        hash = "sha256:1c4bpyh61ampjgk5yh3inrgcpf1z1xv0pshn54ycmpn4dyzv0p2x";
        package = "packages/base-threads/base-threads.base";
      };
      pname = "base-threads";
      src = null;
      version = "base";
    };
    base-unix = 
    {
      opamInputs = {
      };
      opamSrc = repoPath (repos.opam-repository.src) 
      {
        hash = "sha256:0mpsvb7684g723ylngryh15aqxg3blb7hgmq2fsqjyppr36iyzwg";
        package = "packages/base-unix/base-unix.base";
      };
      pname = "base-unix";
      src = null;
      version = "base";
    };
    biniou = 
    {
      opamInputs = 
      {
        dune = selection.dune;
        easy-format = selection.easy-format;
        ocaml = selection.ocaml;
      };
      opamSrc = repoPath (repos.opam-repository.src) 
      {
        hash = "sha256:12ykyqa9piw1gny1flsi43qph411alzsm3rr8cgs5ap4drk3xbrd";
        package = "packages/biniou/biniou.1.2.1";
      };
      pname = "biniou";
      src = pkgs.fetchurl 
      {
        sha256 = "0da3m0g0dhl02jfynrbysjh070xk2z6rxcx34xnqx6ljn5l6qm1m";
        url = "https://github.com/mjambon/biniou/releases/download/1.2.1/biniou-1.2.1.tbz";
      };
      version = "1.2.1";
    };
    conf-m4 = 
    {
      buildInputs = [ (pkgs.m4) ];
      opamInputs = {
      };
      opamSrc = repoPath (repos.opam-repository.src) 
      {
        hash = "sha256:1jlhg718lz35jyr5w0sgvg5ycplhnd8653rc4980yci8p3z1vlxs";
        package = "packages/conf-m4/conf-m4.1";
      };
      pname = "conf-m4";
      src = null;
      version = "1";
    };
    cppo = 
    {
      opamInputs = 
      {
        base-unix = selection.base-unix;
        dune = selection.dune;
        ocaml = selection.ocaml;
      };
      opamSrc = repoPath (repos.opam-repository.src) 
      {
        hash = "sha256:0hdl429cpb4bg9gc07rxs14p7d3r3nfi3vw6s38c6xhf412nl611";
        package = "packages/cppo/cppo.1.6.6";
      };
      pname = "cppo";
      src = pkgs.fetchurl 
      {
        sha256 = "185q0x54id7pfc6rkbjscav8sjkrg78fz65rgfw7b4bqlyb2j9z7";
        url = "https://github.com/ocaml-community/cppo/releases/download/v1.6.6/cppo-v1.6.6.tbz";
      };
      version = "1.6.6";
    };
    csexp = 
    {
      opamInputs = 
      {
        dune = selection.dune;
        ocaml = selection.ocaml;
        ppx_expect = selection.ppx_expect or null;
        result = selection.result;
      };
      opamSrc = repoPath (repos.opam-repository.src) 
      {
        hash = "sha256:1fv3hpd6ida5d64lni1203ngvlbm0fpyqslp6lkdrv7yip5ifkr0";
        package = "packages/csexp/csexp.1.3.1";
      };
      pname = "csexp";
      src = pkgs.fetchurl 
      {
        sha256 = "0maihbqbqq9bwr0r1cv51r3m4hrkx9cf5wnxcz7rjgn13lcc9s49";
        url = "https://github.com/ocaml-dune/csexp/releases/download/1.3.1/csexp-1.3.1.tbz";
      };
      version = "1.3.1";
    };
    dune = 
    {
      opamInputs = 
      {
        base-threads = selection.base-threads;
        base-unix = selection.base-unix;
        ocaml = selection.ocaml or null;
        ocamlfind-secondary = selection.ocamlfind-secondary or null;
      };
      opamSrc = repoPath (repos.opam-repository.src) 
      {
        hash = "sha256:0l49rpphilvzkss69710fpyjnsnnicvpi0giyplbzq9p31fjf2vc";
        package = "packages/dune/dune.2.7.0";
      };
      pname = "dune";
      src = pkgs.fetchurl 
      {
        sha256 = "058wiyncczbmlfxj3cnwn5n68wkmbaf4mgjm2bkp2hffpn2wl5xl";
        url = "https://github.com/ocaml/dune/releases/download/2.7.0/dune-2.7.0.tbz";
      };
      version = "2.7.0";
    };
    dune-build-info = 
    {
      opamInputs = 
      {
        dune = selection.dune;
        odoc = selection.odoc or null;
      };
      opamSrc = repoPath (repos.opam-repository.src) 
      {
        hash = "sha256:07b25gpkcz8ibqrr0hmsyw0ldvn3ddjzl0cabxc0br38dhmzs4lm";
        package = "packages/dune-build-info/dune-build-info.2.7.0";
      };
      pname = "dune-build-info";
      src = pkgs.fetchurl 
      {
        sha256 = "058wiyncczbmlfxj3cnwn5n68wkmbaf4mgjm2bkp2hffpn2wl5xl";
        url = "https://github.com/ocaml/dune/releases/download/2.7.0/dune-2.7.0.tbz";
      };
      version = "2.7.0";
    };
    easy-format = 
    {
      opamInputs = 
      {
        dune = selection.dune;
        ocaml = selection.ocaml;
      };
      opamSrc = repoPath (repos.opam-repository.src) 
      {
        hash = "sha256:1zahpwp0021xygbwpygrrwa5g65qq6dfqngckb3823ybc6l79lva";
        package = "packages/easy-format/easy-format.1.3.2";
      };
      pname = "easy-format";
      src = pkgs.fetchurl 
      {
        sha256 = "09hrikx310pac2sb6jzaa7k6fmiznnmhdsqij1gawdymhawc4h1l";
        url = "https://github.com/mjambon/easy-format/releases/download/1.3.2/easy-format-1.3.2.tbz";
      };
      version = "1.3.2";
    };
    menhir = 
    {
      opamInputs = 
      {
        dune = selection.dune;
        menhirLib = selection.menhirLib;
        menhirSdk = selection.menhirSdk;
        ocaml = selection.ocaml;
      };
      opamSrc = repoPath (repos.opam-repository.src) 
      {
        hash = "sha256:04j4p62msqwji50pcz96nk395nzjldx429ykh37gmqj0hyhxqly1";
        package = "packages/menhir/menhir.20200624";
      };
      pname = "menhir";
      src = pkgs.fetchurl 
      {
        sha256 = "13m5hy1lvcpiybc1r15cfd1n7gnpbybly8if7lg6fc7j5bhp0df1";
        url = "https://gitlab.inria.fr/fpottier/menhir/repository/20200624/archive.tar.gz";
      };
      version = "20200624";
    };
    menhirLib = 
    {
      opamInputs = 
      {
        dune = selection.dune;
        ocaml = selection.ocaml;
      };
      opamSrc = repoPath (repos.opam-repository.src) 
      {
        hash = "sha256:017hgb1nim210y85zqls45gwqbcz2d7xr35h27cy3wn84kjxgl59";
        package = "packages/menhirLib/menhirLib.20200624";
      };
      pname = "menhirLib";
      src = pkgs.fetchurl 
      {
        sha256 = "13m5hy1lvcpiybc1r15cfd1n7gnpbybly8if7lg6fc7j5bhp0df1";
        url = "https://gitlab.inria.fr/fpottier/menhir/repository/20200624/archive.tar.gz";
      };
      version = "20200624";
    };
    menhirSdk = 
    {
      opamInputs = 
      {
        dune = selection.dune;
        ocaml = selection.ocaml;
      };
      opamSrc = repoPath (repos.opam-repository.src) 
      {
        hash = "sha256:0hmzhm4yc69rs2dzx9s7spi9898p2srahy7jbhjw17v2vgx3dpfs";
        package = "packages/menhirSdk/menhirSdk.20200624";
      };
      pname = "menhirSdk";
      src = pkgs.fetchurl 
      {
        sha256 = "13m5hy1lvcpiybc1r15cfd1n7gnpbybly8if7lg6fc7j5bhp0df1";
        url = "https://gitlab.inria.fr/fpottier/menhir/repository/20200624/archive.tar.gz";
      };
      version = "20200624";
    };
    ocaml = 
    {
      opamInputs = 
      {
        ocaml-base-compiler = selection.ocaml-base-compiler or null;
        ocaml-config = selection.ocaml-config;
        ocaml-system = selection.ocaml-system or null;
        ocaml-variants = selection.ocaml-variants or null;
      };
      opamSrc = repoPath (repos.opam-repository.src) 
      {
        hash = "sha256:1j9xgxnbgzrar4rwynm7jd0bi3f5qwwkgyxvk1pd8iazvn81pgya";
        package = "packages/ocaml/ocaml.4.10.0";
      };
      pname = "ocaml";
      src = null;
      version = "4.10.0";
    };
    ocaml-base-compiler = 
    {
      opamInputs = {
      };
      opamSrc = repoPath (repos.opam-repository.src) 
      {
        hash = "sha256:0wavwn6cq999v787fsxf0v2z71h1vwhxwqbidznc4f9ccwjcdc76";
        package = "packages/ocaml-base-compiler/ocaml-base-compiler.4.10.0";
      };
      pname = "ocaml-base-compiler";
      src = pkgs.fetchurl 
      {
        sha256 = "0fdw4abyp37q7acqaqawy64gakpg7xckw5ssfpn8dbwxlzqf1fjq";
        url = "https://github.com/ocaml/ocaml/archive/4.10.0.tar.gz";
      };
      version = "4.10.0";
    };
    ocaml-config = 
    {
      opamInputs = 
      {
        ocaml-base-compiler = selection.ocaml-base-compiler or null;
        ocaml-system = selection.ocaml-system or null;
        ocaml-variants = selection.ocaml-variants or null;
      };
      opamSrc = repoPath (repos.opam-repository.src) 
      {
        hash = "sha256:0g5s0yysgqdrbgx7vyh56fhx59xypw6hdwlcbzbqcgvj4zp4yy0c";
        package = "packages/ocaml-config/ocaml-config.1";
      };
      pname = "ocaml-config";
      src = null;
      version = "1";
    };
    ocaml-lsp-server = 
    {
      opamInputs = 
      {
        csexp = selection.csexp;
        dune = selection.dune;
        dune-build-info = selection.dune-build-info;
        menhir = selection.menhir;
        ocaml = selection.ocaml;
        ocamlfind = selection.ocamlfind;
        ocamlformat = selection.ocamlformat or null;
        ppx_yojson_conv_lib = selection.ppx_yojson_conv_lib;
        reason = selection.reason or null;
        result = selection.result;
        stdlib-shims = selection.stdlib-shims;
        yojson = selection.yojson;
      };
      opamSrc = "ocaml-lsp-server.opam";
      pname = "ocaml-lsp-server";
      src = self.directSrc "ocaml-lsp-server";
      version = "development";
    };
    ocamlfind = 
    {
      opamInputs = 
      {
        conf-m4 = selection.conf-m4;
        graphics = selection.graphics or null;
        ocaml = selection.ocaml;
      };
      opamSrc = repoPath (repos.opam-repository.src) 
      {
        hash = "sha256:04z3rq1y20wfzmwvjm9wlg89cqqs8n37inhbwp4x2dsqbn0hqd81";
        package = "packages/ocamlfind/ocamlfind.1.8.1";
      };
      pname = "ocamlfind";
      src = pkgs.fetchurl 
      {
        sha256 = "00s3sfb02pnjmkax25pcnljcnhcggiliccfz69a72ic7gsjwz1cf";
        url = "http://download.camlcity.org/download/findlib-1.8.1.tar.gz";
      };
      version = "1.8.1";
    };
    ppx_yojson_conv_lib = 
    {
      opamInputs = 
      {
        dune = selection.dune;
        ocaml = selection.ocaml;
        yojson = selection.yojson;
      };
      opamSrc = repoPath (repos.opam-repository.src) 
      {
        hash = "sha256:009x6jphkby3dqzcjafg9fyv4jlnf50bx23gy290m1cqs1mr1d89";
        package = "packages/ppx_yojson_conv_lib/ppx_yojson_conv_lib.v0.14.0";
      };
      pname = "ppx_yojson_conv_lib";
      src = pkgs.fetchurl 
      {
        sha256 = "1f1530pvyg05zwi83iwrk3v207w316wlljikwyl9ahjh24lsja46";
        url = "https://ocaml.janestreet.com/ocaml-core/v0.14/files/ppx_yojson_conv_lib-v0.14.0.tar.gz";
      };
      version = "v0.14.0";
    };
    result = 
    {
      opamInputs = 
      {
        dune = selection.dune;
        ocaml = selection.ocaml;
      };
      opamSrc = repoPath (repos.opam-repository.src) 
      {
        hash = "sha256:1c7lw8dbchllz3rl801xwpm82r427vnrv7b7kqh0gwjglya50y28";
        package = "packages/result/result.1.5";
      };
      pname = "result";
      src = pkgs.fetchurl 
      {
        sha256 = "0cpfp35fdwnv3p30a06wd0py3805qxmq3jmcynjc3x2qhlimwfkw";
        url = "https://github.com/janestreet/result/releases/download/1.5/result-1.5.tbz";
      };
      version = "1.5";
    };
    stdlib-shims = 
    {
      opamInputs = 
      {
        dune = selection.dune;
        ocaml = selection.ocaml;
      };
      opamSrc = repoPath (repos.opam-repository.src) 
      {
        hash = "sha256:041f37xj7k9np8fkn3ccp5594a198ijivjndqdzi0a3sr587a5p9";
        package = "packages/stdlib-shims/stdlib-shims.0.1.0";
      };
      pname = "stdlib-shims";
      src = pkgs.fetchurl 
      {
        sha256 = "1jv6yb47f66239m7hsz7zzw3i48mjpbvfgpszws48apqx63wjwsk";
        url = "https://github.com/ocaml/stdlib-shims/releases/download/0.1.0/stdlib-shims-0.1.0.tbz";
      };
      version = "0.1.0";
    };
    yojson = 
    {
      opamInputs = 
      {
        alcotest = selection.alcotest or null;
        biniou = selection.biniou;
        cppo = selection.cppo;
        dune = selection.dune;
        easy-format = selection.easy-format;
        ocaml = selection.ocaml;
      };
      opamSrc = repoPath (repos.opam-repository.src) 
      {
        hash = "sha256:1vxmg1yiwh1wgxwwqzfrvaaff4wxanakq2yap1s2x3h54fqakkza";
        package = "packages/yojson/yojson.1.7.0";
      };
      pname = "yojson";
      src = pkgs.fetchurl 
      {
        sha256 = "1iich6323npvvs8r50lkr4pxxqm9mf6w67cnid7jg1j1g5gwcvv5";
        url = "https://github.com/ocaml-community/yojson/releases/download/1.7.0/yojson-1.7.0.tbz";
      };
      version = "1.7.0";
    };
  };
}

