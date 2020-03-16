# The environment that it used to execute the notebooks.
let
  fetchTarballFromGitHub = {repo, owner, rev, sha256}: fetchTarball {
    url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
    inherit sha256;
  };

  nixpkgs = fetchTarballFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "64565f9d8ffe5bc3737ebd5f6b97756fac16d23b";
    sha256 = "1n31xffqi1lfaf44k38z6bx7g4scj5nibx9zcnf06mqn4fzakgd6";
  };

  pkgs = import nixpkgs {};

  python = pkgs.python3;

  pandoc = (import (fetchTarballFromGitHub {
    owner = "Mic92";
    repo = "nur-packages";
    rev = "0c3d7e8545a8f01e72fb79d3f17137267e9c20dc";
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
