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
        overlays = [
          haskellNix.overlay
          (final: _prev: {
            gclProject = final.haskell-nix.stackProject' {
              src = ./.;
              compiler-nix-name = "ghc984";

              shell = {
                tools = {
                  stack = {};
                  haskell-language-server = {};
                  ormolu = {};
                };

                buildInputs = with pkgs; [
                  nixpkgs-fmt
                ];
              };
            };
          })
        ];

        pkgs = import nixpkgs {
          inherit system overlays;
          inherit (haskellNix) config;
        };

        flake = pkgs.gclProject.flake {};
      in flake // {
        packages.default = flake.packages."gcl:exe:gcl";
      }
    );
}
