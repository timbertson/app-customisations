self: super:
let
	# TODO: need to figure out a more portable system than pins
	nixPin = super.nix-pin.api {};
in
{
	features = super.features // {
		maximal = true;
		systemd = true;
		vim-ide = true;
	};
	# pins = nixPin.pins;
	# gup-ocaml = nixPin.pins.gup or super.gup-ocaml;
	# opam2nix = nixPin.pins.opam2nix or super.opam2nix;
}
