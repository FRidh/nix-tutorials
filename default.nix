# The environment that it used to execute the notebooks.
let
  nixpkgs = fetchGit {
    url = https://github.com/NixOS/nixpkgs.git;
    ref = "nixos-19.09";
    rev = "64565f9d8ffe5bc3737ebd5f6b97756fac16d23b";
  };
#with import (fetchTarball "channel:nixos-19.09") {};

  pkgs = import nixpkgs {};

  python = pkgs.python3.withPackages(ps: with ps; [ jupyterlab ]);
in pkgs.mkShell {
  buildInputs = [
    python
    pkgs.nix
  ];

  shellHook = ''
    ${python}/bin/jupyter-lab
  '';
}
