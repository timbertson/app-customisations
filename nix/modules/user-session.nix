{ config, lib, pkgs, utils, ... }:
let
	sd = import <nixpkgs/nixos/modules/system/boot/systemd-lib.nix> { inherit config lib pkgs; };
in
{
	config = {
		systemd.user = {
			services.test = {};
		};
		system.build.standalone-user-units = sd.generateUnits
			"user" # type
			config.systemd.user.units
			"" # upstreamUnits
			"" # upstreamWants
		;
	};
}
