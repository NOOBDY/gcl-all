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

        stack-wrapped = pkgs.symlinkJoin {
          name = "stack"; # will be available as the usual `stack` in terminal
          paths = [ pkgs.stack ];
          buildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/stack \
              --add-flags "\
                --no-nix \
                --system-ghc \
                --no-install-ghc \
              "
          '';
        };

        overlays = [
          haskellNix.overlay
          (final: prev: {
            gclProject = final.haskell-nix.stackProject' {
              src = pkgs.haskell-nix.cleanSourceHaskell {
                src = ./.;
                name = "gcl";
              };

              compiler-nix-name = "ghc984";

              shell = {
                tools = {
                  # stack = "3.3.1";
                  hlint = {};
                  haskell-language-server = {};
                  ormolu = {};
                };

                buildInputs = with pkgs; [
                  #(pkgs.writeScriptBin "haskell-language-server-wrapper" ''
                  #  #!${pkgs.stdenv.shell}
                  #  exec haskell-language-server "$@"
                  #'')
                ];

                withHoogle = false;
              };
            };
          })
        ];

        flake = pkgs.gclProject.flake {};
      in flake // {
        packages.default = flake.packages."gcl:exe:gcl";
      }
    );
}
