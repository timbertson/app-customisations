{pkgs, gsel ? null, vim-watch }:
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
		"https://github.com/mileszs/ack.vim/archive/1.0.9.tar.gz"
		"1arcann0jkdr5z1393n2i379w0m5k4znz8ky08l69201xmggb2jr";

	"asyncrun" = mkgit
		"https://github.com/skywind3000/asyncrun.vim"
		"8f419d9be2377d33bb3f6848b1bf2e2b3be9fd07"
		"0daxd33sw3rf3q5jlg6a7d14qfdfygyr4ndi7mvxyavjx2i5mgb7";

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

	"vim-grepper" = mkgit
		"https://github.com/mhinz/vim-grepper"
		"aba22535b1ab4011dbb7e627a4294530d1f29a04"
		"09r7lsazskb1yy63inhbjgh456idcay6175m0b5izadzq9nr58rc";
	
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

	"targets" = mkgit
		"https://github.com/wellle/targets.vim"
		"c12d4ea9e5032c9e5b88e2115a80b8772d15d0df"
		"11n95r6ahq8y41qmvcadrr1smmd13iffiny0sx336k747m9mvwfq";

	"tcomment" = mkurl
		"https://github.com/tomtom/tcomment_vim/archive/3.07.tar.gz"
		"04dplapgh8z90174pxr6iacwizlblizgn8158w07cdg7xds3gww5";

	"vala.vim" = mkgit
		"https://github.com/arrufat/vala.vim.git"
		"d987cdb93daae420b69c3b1d803a85d6e1d10494"
		"15g221ivyg1dzr4ddvx9cdz0lshg7kzfyn8mnrcskq1h7aqsrsqz"
		;

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
		"https://github.com/gfxmonk/indent-finder"
		"4b92a176d2980c5fa4352232495eba416d777022"
		"05xx8nz64v24chdb84jv17b33j7aaz0bc7mrj9gxinzbzj4bin22";
	
	"gsel" = if gsel == null then null else mk { src = "${gsel}/share/vim"; };
	# "gsel" = if builtins.pathExists "/home/tim/dev/ocaml/gsel/vim" then mk { src = /home/tim/dev/ocaml/gsel/vim; } else null;

}
