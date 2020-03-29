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

  # Binder runs Nix inside Docker. Sandboxing is not possible.
  nixConf = (pkgs.runCommand "nix.conf" {} ''
      mkdir -p $out/etc
      cat << EOF > $out/etc/nix.conf
      sandbox = false
      EOF
    '');

  runDeps = [
    (python.withPackages(ps: with ps; [
      notebook # Needed for Binder 
    ]))
    pkgs.nix
    nixConf
  ];

  devDeps = [
    (python.withPackages(ps: with ps; [
      notebook # Needed for Binder 
      jupyterlab # For development
      sphinx # For generating docs
      nbsphinx # For including the notebooks in docs
    ]))
    pkgs.nix
    pkgs.gitMinimal
    pandoc  # Required by nbsphinx...sigh
    pkgs.gnumake
  ];

  devEnv = pkgs.mkShell {
    name = "nix-tutorials-dev-env";
    buildInputs = devDeps;
  };

  runEnv = let
    env = pkgs.buildEnv {
      name = "nix-tutorials-run-env";
      paths = runDeps;
    };
  in pkgs.mkShell {
    # Make runEnv available for binder.
    # Do not include devEnv here because of closure size.
    #
    # We use mkShell, not because it runs hooks (we do not want that)
    # but because we simply need to be able to export an environment variable
    # which buildEnv doesn't allow.
    inherit (env) name;
    buildInputs = [ env ];

    # Use a nix.conf file with binder
    NIX_CONF_DIR="${env}/etc";
  };

  # Utility that given a filename cleans the notebook of its output.
  # TODO: broken because of https://github.com/jupyter/nbconvert/issues/822
  clean-notebook = pkgs.writeShellScriptBin "clean-notebook" ''
     ${python.pkgs.nbconvert}/bin/jupyter-nbconvert --ClearMetadataPreprocessor.enabled=True --ClearOutput.enabled=True --to=notebook $1
  '';

  # Validate the notebook purely. In this case, that means testing it does not have any output.
  # TODO: broken because of https://github.com/jupyter/nbconvert/issues/822
  test-notebook = pkgs.writeShellScriptBin "test-notebook" ''
    if [ ! -f "$1" ]; then
      echo "Error: file $1 does not exist"
      exit 1
    fi
    bname=$(basename -- "$1")
    fname="''${bname%.*}"
    dname=$(dirname "$1")
    echo "Testing notebook $1"

    ${python.pkgs.nbconvert}/bin/jupyter-nbconvert --ClearMetadataPreprocessor.enabled=True --ClearOutput.enabled=True --to=notebook --output="$fname-cleaned.ipynb" "$1"
    diff "$1" "$dname/$fname-cleaned.ipynb"
    rm "$dname/$fname-cleaned.ipynb"
  '';

  # Test all notebooks purely
  testsPure = pkgs.stdenv.mkDerivation {
    name = "nix-tutorials-pure-tests";
    src = fetchGit ./.;

    buildPhase = ''
      shopt -s globstar
      for tutorial in tutorials/**/*.ipynb; do
        ${test-notebook}/bin/test-notebook "$tutorial"
      done
    '';
    installPhase = ''
      echo success > $out
    '';
  };

in {
  inherit devDeps runDeps devEnv runEnv clean-notebook test-notebook testsPure pkgs;
}
