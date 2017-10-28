{pkgs ? import <nixpkgs> {}, enableNeovim ? false }:
with pkgs;
let
	home = builtins.getEnv "HOME";
	tryInvoke = fn: path: if builtins.pathExists path
		then fn (builtins.toPath path)
		else null;

	tryBuildHaskell = tryInvoke (path:
		pkgs.haskell.packages.ghc7102.callPackage path { }
	);
	tryImport = path: args: tryInvoke (path:
		import path ({ inherit pkgs; } // args)
	) path;
	tryCallPackage = path: args: tryInvoke (path: callPackage path args) path;

	default = dfl: obj: if obj == null then dfl else obj;
	opam2nix-packages = callPackage ./opam2nix-packages.nix {};
	buildFromSource = jsonFile: attrs:
		let
			fetched = pkgs.nix-update-source.fetch jsonFile;
			pkg = (callPackage "${fetched.src}/nix/default.nix" attrs);
		in
		lib.overrideDerivation pkg (base: {
			name = "${fetched.repo}-${fetched.version or fetched.fetch.version}";
			inherit (fetched) src;
		});
in
pkgs // rec {
	inherit tryImport default buildFromSource;
	daglink = buildFromSource ./sources/daglink.json {};
	dconf-user-overrides = tryImport "${home}/dev/python/dconf-user-overrides/nix/local.nix" {};
	dns-alias = tryCallPackage "${home}/dev/python/dns-alias/nix/default.nix" { inherit pythonPackages; };
	dumbattr = tryImport "${home}/dev/python/dumbattr/nix/local.nix" {};
	eog-rate = tryImport "${home}/dev/python/eog-rate/nix/local.nix" {};
	gsel = tryImport "${home}/dev/ocaml/gsel/default.nix" {};
	gup = default pkgs.gup (tryImport "${home}/dev/ocaml/gup/local.nix" {});
	irank = tryImport "${home}/dev/python/irank/default.nix" {};
	irank-releases = callPackage ./irank-releases.nix { inherit irank; };
	jsonnet = callPackage ./jsonnet.nix {};
	music-import = tryImport "${home}/dev/python/music-import/nix/local.nix" {};
	my-borg-task = callPackage ./my-borg-task.nix {};
	my-nix-prefetch-scripts = callPackage ./nix-prefetch-scripts.nix {};
	opam2nix = opam2nix-packages.opam2nix;
	passe-client = tryImport "${home}/dev/ocaml/passe-stable/nix/local.nix" { target="client"; opam2nix = opam2nix-packages; };
	pyperclip = callPackage ./pyperclip.nix {};
	pythonPackages = pkgs.pythonPackages // {
		dnslib = tryCallPackage "${home}/dev/python/dns-alias/nix/dnslib.nix" { inherit pythonPackages; };
	};
	shellshape = tryImport "${home}/dev/gnome-shell/shellshape@gfxmonk.net/default.nix" {};
	snip = tryBuildHaskell "${home}/dev/haskell/snip/nix/default.nix" ;
	template = tryImport "${home}/dev/python/template/default.nix" {};
	trash = tryImport "${home}/dev/python/trash/default.nix" {};
	vim = (callPackage ./vim.nix { pluginArgs = { inherit vim-watch; }; });
	neovim = vim.neovim;

	vim-watch = default
		(buildFromSource ./sources/vim-watch.json { inherit enableNeovim; })
		(tryImport "${home}/dev/vim/vim-watch/nix/local.nix" { inherit enableNeovim; });
}
