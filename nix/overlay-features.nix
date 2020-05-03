self: super:
with builtins;
with super.lib;

let
	# TODO: this should be a home-manager module when it's all ported
	defaultFeatures = {
		node = true;
		maximal = false;
		git-readonly = false;
		gnome-shell = false;
		jdk = false;
		systemd = false;
		vim-ide = false;
		linux = super.stdenv.isLinux;
		osx = super.stdenv.isDarwin;
	};
in
{
	siteLib = rec {
		orNull = cond: x: if cond then x else null;

		isEnabled = feature:
			if (!hasAttr feature defaultFeatures) then
				lib.warn "Unknown feature: ${feature}" (assert false; null)
			else getAttr feature self.features;

		ifEnabled = feature: x: orNull (isEnabled feature) x;

		anyEnabled = features: x: orNull (any isEnabled features) x;
	};
	features = defaultFeatures;
}
