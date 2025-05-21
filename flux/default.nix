{ pkgs, nix2container, ... }:

let

  buildAllControllers = pkgs.writeShellApplication {
    name = "flux-all";
    text = builtins.readFile ./scripts/flux-all.sh;
  };

in
{

  helm-controller = (import ./helm-controller.nix { inherit pkgs nix2container; }).helm-controller;
  kustomize-controller =
    (import ./kustomize-controller.nix { inherit pkgs nix2container; }).kustomize-controller;
  notification-controller =
    (import ./notification-controller.nix { inherit pkgs nix2container; }).notification-controller;
  source-controller =
    (import ./source-controller.nix { inherit pkgs nix2container; }).source-controller;

  all = buildAllControllers;

}
