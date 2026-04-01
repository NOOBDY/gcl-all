{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
  outputs = { self, nixpkgs }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];

      forEachSupportedSystem = f:
        nixpkgs.lib.genAttrs supportedSystems (
          system:
          let
            pkgs = import nixpkgs {
              inherit system;
            };
          in
          f {
            inherit system pkgs;
            hPkgs = pkgs.haskell.packages."ghc984";
          }
        );
    in
    {
      devShells = forEachSupportedSystem (
        {pkgs, hPkgs, system}:
        let
          devTools = with hPkgs; [
            ghc
            haskell-language-server
            ormolu

            stack-wrapped
            pkgs.zlib
          ];

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
        in
        {
          default = pkgs.mkShellNoCC {
            buildInputs = devTools;

            LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath devTools;
          };
        }
      );
    };
}
