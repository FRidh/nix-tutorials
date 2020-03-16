# The environment that it used to execute the notebooks.
let
  nixpkgs = fetchGit {
    url = https://github.com/NixOS/nixpkgs.git;
    ref = "nixos-19.09";
    rev = "64565f9d8ffe5bc3737ebd5f6b97756fac16d23b";
  };

  pkgs = import nixpkgs {};

  python = pkgs.python3;

  pandoc = (import (fetchTarball {
    url = "https://github.com/Mic92/nur-packages/archive/0c3d7e8545a8f01e72fb79d3f17137267e9c20dc.tar.gz";
    sha256 = "0c0dg4177kwmgfnpv15sbgd2x1l04bgddw9qnr8qsj4b8dpp945i";
  }) {inherit pkgs;}).pandoc-bin;  # Much smaller, faster CI

  runDeps = [
    (python.withPackages(ps: with ps; [
      notebook # Needed for Binder 
    ]))
    pkgs.nix
  ];

  devDeps = [
    (python.withPackages(ps: with ps; [
      notebook # Needed for Binder 
      jupyterlab # For development
      sphinx # For generating docs
      nbsphinx # For including the notebooks in docs
    ]))
    pkgs.nix
    pandoc  # Required by nbsphinx...sigh
    pkgs.gnumake
  ];

  devEnv = pkgs.mkShell {
    name = "nix-tutorials-dev-env";
    buildInputs = devDeps;
  };

  runEnv = pkgs.buildEnv {
    name = "nix-tutorials-run-env";
    paths = runDeps;
  };

in pkgs.mkShell {
  # Make runEnv available for binder.
  # Do not include devEnv here because of closure size.
  buildInputs = [ 
    runEnv
  ];

  passthru = {
    inherit devEnv runEnv;
  };
}
