{ pkgs ? import <nixpkgs> {}}:
with pkgs.python3Packages;
python-language-server.override { providers = []; }
