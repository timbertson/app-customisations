{pkgs, gsel ? null, vim-watch
}:
with pkgs;
let
	url = url: sha: fetchurl { url = url; sha256 = sha; };
	mk = def: vimUtils.buildVimPlugin ({
		name = "vim-plugin";
	} // def);
	mkurl = url: sha256: mk { src = fetchurl { inherit url sha256; }; };
	mkgit = url: rev: sha256: mk { src = fetchgit { inherit url rev sha256; }; };
in
{
	"ack.vim" = mkurl
		"https://github.com/mileszs/ack.vim/archive/1.0.8.tar.gz"
		"0xxxnipbh9xqn4bbviy1z932na64bscdx2sswpndf5dqwp67s8ch";

	"vim-nix" = mkgit
		"https://github.com/spwhitt/vim-nix"
		"636b8bc437bd0a24a4202a7d906b2b40eac219fa"
		"69e982e09d2fb58928a658dc2ecf44bb5e4419161de30646d9848b3f27614249";

	"fish-syntax" = mkurl
		"https://github.com/vim-scripts/fish-syntax/archive/4.tar.gz"
		"15cjlnldz0mbrrs6jv8rbf3s1zfj4c6p950r44j11ap8h701n114";

	"ir-black" = mkgit
		"https://github.com/wesgibbs/vim-irblack"
		"59622caff32a7925181ab139701fad3eee54ae51"
		"9eb05b53c8ad6f06b55eee466ead7dbb979cf9f64bd622a809fb200d0c42daea";

	"repeat" = mkgit
		"https://github.com/tpope/vim-repeat"
		"7a6675f092842c8f81e71d5345bd7cdbf3759415"
		"87e69508784baa66d13478c7a75672c5106a00bb12e52069312750bf872f0f5d";

	"vim-indent-object" = mkgit
		"https://github.com/michaeljsmith/vim-indent-object"
		"1d3e4aac0117d57c3e1aaaa7e5a99f1d7553e01b"
		"b9b044052f02010089589beefa1b1cad60603a29a940504ce380c57cdc9174cf";
	
	"vim-rust" = mkgit
		"https://github.com/rust-lang/rust.vim"
		"fa1bccc2bfc223326fb28869ed0461f39c7fa04a"
		"8fb3e69a8834e65f1b33f2cc83b1ad36e65b273ea14443a43f2cbc9d66307f42";
	
	"vim-stratifiedjs" = (mk {
		src = fetchurl {
			url = "https://github.com/onilabs/stratifiedjs/archive/v0.19.0.tar.gz";
			sha256 = "1792gbx8j5zrykvs2ln5qayr6gks5x93qd9ar7whk9npla569rg3";
		};
		preBuild = "cd vim/stratifiedjs";
	});

	"tcomment" = mkurl
		"https://github.com/tomtom/tcomment_vim/archive/3.07.tar.gz"
		"04dplapgh8z90174pxr6iacwizlblizgn8158w07cdg7xds3gww5";

	"vim-visual-star-search" = mkurl
		"https://github.com/bronson/vim-visual-star-search/archive/0.2.tar.gz"
		"1xxdy8m0dcmwvxalypwmjkd5737ma8mj2zhi7lsccfspyf8b7gzk";

	"vim-watch" = mk { src = "${vim-watch}/share/vim"; };
	
	# TODO delete this or make it proper?
	"misc" = mk {
		src = ../vim;
		buildPhase = "rm -rf ./cache";
	};

	"indent-finder" = mkgit
		# "https://github.com/ldx/vim-indentfinder"
		"https://github.com/gfxmonk/indent-finder"
		"4b92a176d2980c5fa4352232495eba416d777022"
		"9f2be3c327d374809ac214af0b41779ead008f1c6643858d0cfecfb58470e5e9";
	
	"gsel" = if gsel == null then null else mk { src = "${gsel}/share/vim"; };
	# "gsel" = if builtins.pathExists "/home/tim/dev/ocaml/gsel/vim" then mk { src = /home/tim/dev/ocaml/gsel/vim; } else null;

}
