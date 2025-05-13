{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    nix2container.url = "github:nlewo/nix2container";
  };

  outputs =
    {
      self,
      nixpkgs,
      systems,
      treefmt-nix,
      pre-commit-hooks,
      nix2container,
    }:
    let
      # lastModifiedDate = self.lastModifiedDate or self.lastModified or "19700101";
      # version = builtins.substring 0 8 lastModifiedDate;

      forEachSystem =
        f: nixpkgs.lib.genAttrs (import systems) (system: f nixpkgs.legacyPackages.${system});
      treefmtEval = forEachSystem (pkgs: treefmt-nix.lib.evalModule pkgs ./nix/treefmt.nix);
      # nix2containerPkgs = forEachSystem (pkgs: (nix2container.packages.${pkgs.system}));
    in
    {
      formatter = forEachSystem (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);
      checks = forEachSystem (pkgs: {
        pre-commit-check = pkgs.callPackage ./nix/pre-commit.nix {
          inherit pre-commit-hooks treefmtEval;
        };
      });
      packages = forEachSystem (pkgs: {
        external-dns = import ./external-dns { inherit pkgs nix2container; };
      });
      devShell = forEachSystem (
        pkgs:
        pkgs.mkShell {
          buildInputs = with pkgs; [
            go
            gopls
            gotools
            dive
            grype
            trivy
            upx
            (self.checks.${pkgs.system}.pre-commit-check.enabledPackages)
            treefmtEval.${pkgs.system}.config.build.wrapper
          ];
        }
      );
    };
}
