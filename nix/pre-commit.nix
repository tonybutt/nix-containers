{
  pkgs,
  pre-commit-hooks,
  treefmtEval,
}:
pre-commit-hooks.lib.${pkgs.system}.run {
  src = ../.;
  hooks = {
    flake-checker.enable = true;
    treefmt-nix = {
      enable = true;
      entry = "${treefmtEval.${pkgs.system}.config.build.wrapper}/bin/treefmt --ci";
      pass_filenames = false;
    };
    convco.enable = true;
  };
}
