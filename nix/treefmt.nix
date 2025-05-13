{ ... }:
{
  projectRootFile = "flake.nix";
  settings.global.excludes = [
    "**/.version"
    "*.age"
    "*.svg"
    "*.png"
    "**/kubeconfig-example"
    "CODEOWNERS"
    ".envrc"
    "*.tmpl"
    "docs/templates/*.html"
    ".golangci.yml"
  ];
  programs = {
    gofmt.enable = true;
    shellcheck.enable = true;
    shfmt.enable = true;
    # Currently, goimports is not working in treefmt, awaiting a fix
    # goimports.enable = true;
    deadnix.enable = true;
    nixfmt.enable = true;
    # Run deadnix first, then run nixfmt by increasing the priority of nixfmt
    nixfmt.priority = 1;
    prettier.enable = true;
    taplo.enable = true;
  };
}
