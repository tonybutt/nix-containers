{
  pkgs,
  pre-commit-hooks,
  treefmtEval,
}:
let
  update-golangci-lint = pkgs.writeShellApplication {
    name = "update-golangci-lint";
    runtimeInputs = [ pkgs.curl ];
    text = builtins.readFile ./shells/scripts/update-golangci-lint.sh;
  };
in
pre-commit-hooks.lib.${pkgs.system}.run {
  src = ../.;
  hooks = {
    update-golangci-lint = {
      enable = true;
      pass_filenames = false;
      stages = [ "pre-push" ];
      entry = "${update-golangci-lint}/bin/update-golangci-lint";
    };
    gotest.enable = true;
    golines.enable = true;
    golangci-lint = {
      enable = true;
      package = pkgs.golangci-lint;
      extraPackages = [ pkgs.go ];
    };
    flake-checker.enable = true;
    treefmt-nix = {
      enable = true;
      entry = "${treefmtEval.${pkgs.system}.config.build.wrapper}/bin/treefmt --ci";
      pass_filenames = false;
    };
    convco.enable = true;
  };
}
