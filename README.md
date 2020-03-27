## Nix tutorials

![Tests](https://github.com/FRidh/nix-tutorials/workflows/Tests/badge.svg?branch=master) [![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/FRidh/nix-tutorials/master)

This repository contains tutorials for using Nix and Nixpkgs written as Jupyter notebooks. The tutorials

- can be [read online](https://fridh.github.io/nix-tutorials)
- or [used interactively](https://mybinder.org/v2/gh/FRidh/nix-tutorials/master) using Binder.

## Developing

Warning: When working on these tutorials, please keep in mind that the notebooks are executed outside of a Nix build. Don't blindly evaluate them.

To open the development environment shell

    nix run -f . devEnv

To open Jupyterlab for writing tutorials

    nix-shell -A devEnv --run "jupyter-lab"

To build the the run-time environment as used by Binder

    nix build -f . runEnv

To compose the documentation

    nix-shell -A devEnv --run "make -C doc html"
