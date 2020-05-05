self:
# TODO this is a bit hacky... we put our called pkgs back
# into the `pkgs` argument of each module,
# to reverse the default nixpkgs module which reimports with
# configured overlays, etc.
{ lib, ... }: {
	config._module.args.pkgs = lib.mkForce self;
}

