self: super:
let
	args = {
		ocaml = super.ocaml-ng.ocamlPackages_4_10.ocaml;
		src = {
			ocaml-lsp-server = super.ocaml-lsp-src;
		};
		selection = ./opam-selection.nix;
	};
in
{
	opam2nixPackages = super.opam2nix.build args;
	opam2nixResolve = super.opam2nix.resolve args [
		"${super.ocaml-lsp-src}/ocaml-lsp-server.opam"
	];
}
