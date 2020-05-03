# Layout

OK, take a deep breath. There's a few layers here.

1. We need some nix: done by ../install.gup
2. Dependency management: for everything we need external to this repo comes in through `nix-wrangle` (see `nix/wrangle*.json`).
   This is bootstrap-friendly, i.e. we only need nix to evaluate-and-fetch these dependencies, we don't need the nix-wrangle binary itself (which will only be available after first build)
3. Then it's all overlays:
  - default.nix sets up all the layers, including some optional overlays for `overlay-$HOSTNAME.nix` and `overlay-local.nix` (uncommitted)
  - overlay-features.nix defines broad configuration options, mainly for opting into minimal setups and host / OS specific differences.
  - overlay-home.nix plugs everything into home-manager, which ends up producing the actual user environment and activation script
    - `modules/` defines custom modules for home-manager
    - `home.packages` extends `pkgs.installedPackages`, which is where the various overlays pop things (not sure how to get an overlay to merge into home-manager)
  - overlay-wrangle.nix imports all wrangle inputs (with a few overridden arguments) and makes them available in `pkgs`, as well as installing them by default

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
