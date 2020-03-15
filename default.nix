# The environment that it used to execute the notebooks.
let
  nixpkgs = fetchGit {
    url = https://github.com/NixOS/nixpkgs.git;
    ref = "nixos-19.09";
    rev = "64565f9d8ffe5bc3737ebd5f6b97756fac16d23b";
  };

  pkgs = import nixpkgs {};

  runDeps = [
    (pkgs.python3.withPackages(ps: with ps; [
      notebook # Needed for Binder 
    ]))
    pkgs.nix
  ];

  devDeps = [
    (pkgs.python3.withPackages(ps: with ps; [
      notebook # Needed for Binder 
      jupyterlab # For development
      sphinx # For generating docs
      nbsphinx # For including the notebooks in docs
    ]))
    pkgs.nix
    pkgs.pandoc  # Required by nbsphinx...sigh
  ];

  devEnv = pkgs.buildEnv {
    name = "nix-tutorials-env";
    paths = devDeps;
  };
in pkgs.mkShell {
  buildInputs = [ 
    devEnv
  ];

#   shellHook = ''
#     ${env}/bin/jupyter-lab
#   '';

#   passthru = {
    # inherit execute-notebooks;
    # inherit container;# tests;
#   };
}
