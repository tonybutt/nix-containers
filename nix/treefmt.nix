{
  projectRootFile = "flake.nix";
  settings.global.excludes = [
    ".envrc"
  ];
  programs = {
    shellcheck.enable = true;
    shfmt.enable = true;
    deadnix.enable = true;
    nixfmt.enable = true;
    # Run deadnix first, then run nixfmt by increasing the priority of nixfmt
    nixfmt.priority = 1;
    prettier.enable = true;
    taplo.enable = true;
  };
}
