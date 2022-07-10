# Layout

OK, take a deep breath. There's a few layers here.

1. We need some nix: done by ../install.gup
2. Dependency management: for everything we need external to this repo comes in through `niv` (see `nix/sources*.json`).
3. Then it's all overlays:
  - default.nix sets up all the layers, including some optional overlays for `overlay-$HOSTNAME.nix` and `overlay-local.nix` (uncommitted)
  - overlay-features.nix defines broad configuration options, mainly for opting into minimal setups and host / OS specific differences.
  - overlay-home.nix plugs everything into home-manager, which ends up producing the actual user environment and activation script
    - `modules/` defines custom modules for home-manager
    - `home.packages` extends `pkgs.installedPackages`, which is where the various overlays pop things (not sure how to get an overlay to merge into home-manager)
  - overlay-niv.nix imports all niv sources and builds the actual packages.

Some nix files are _also_ installed user-wide (with symlinks) to affect general nix usage, they live in shared/

### Build a subcomponent:

The whole system can take a moment to build, so if you're focussing on a component you can usually build it individually:

If it comes from `overlay-*`, everything's mixed into `pkgs` so just run:

```
nix-build -A `<attrName>`
```

If you want to build something from `modules/` or `home.nix`, that's all evaluated as part of home-manager.

It's exposed as `home-config`, so e.g. you can build exposed results via e.g.:

```
nix-build -A home-config.xdg.configFile
```
