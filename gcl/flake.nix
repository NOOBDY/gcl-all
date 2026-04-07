{
  inputs = {
    haskellNix.url = "github:input-output-hk/haskell.nix";
    nixpkgs.follows = "haskellNix/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils, haskellNix }:
    flake-utils.lib.eachSystem [
      "x86_64-linux"
      "aarch64-darwin"
    ]
    (system:
      let
        pkgs = import nixpkgs {
          inherit system overlays;
          inherit (haskellNix) config;
        };

        overlays = [
          haskellNix.overlay
        ];

        project = pkgs.haskell-nix.stackProject' {
          src = pkgs.haskell-nix.cleanSourceHaskell {
            src = ./.;
            name = "gcl";
          };

          compiler-nix-name = "ghc984";
        };

      in {
        packages.default = project.hsPkgs.gcl.components.exes.gcl;

        devShells.default = project.shellFor {
          tools = {
            cabal = {};
            hlint = {};
            haskell-language-server = {};
            ormolu = {};
          };

          buildInputs = [
          ];

          withHoogle = true;
        };
      }
    );
}
