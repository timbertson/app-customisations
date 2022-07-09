# TODO upstream?
attrs:
with builtins;
let
	bootstrap = fromJSON (readFile ./sources.json);
	url = "https://raw.githubusercontent.com/nmattia/niv/${bootstrap.niv.rev}/nix/sources.nix";
in
import (fetchurl url) attrs
