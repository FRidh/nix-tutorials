# The environment that it used to execute the notebooks.

with import (fetchTarball "channel:nixos-19.09") {};

let
  python = python3.withPackages(ps: with ps; [ jupyterlab ]);
in mkShell {
  buildInputs = [
    python
    nix
  ];

  shellHook = ''
    ${python}/bin/jupyter-lab
  '';
}
