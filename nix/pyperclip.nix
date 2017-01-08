{ lib, fetchgit, pythonPackages, which, xsel }:
pythonPackages.buildPythonPackage rec {
  name = "pyperclip-${version}";
  version = "dev";
  src = fetchgit {
    "url" = "https://github.com/timbertson/pyperclip-upstream.git";
    "rev" = "8fed9551596eef6dd8646c2a63d4239b9e5d2fdd";
    "sha256" = "1czxcdlx390ywkaccm69sk1nnlyax4y3ky5bps9yzyj6k8i1xh1w";
  };
  doCheck = false;
  propagatedBuildInputs = [ which xsel ];
}
