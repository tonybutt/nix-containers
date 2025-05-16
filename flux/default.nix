{ pkgs, nix2container, ... }:

let

  helmController = import ./helm-controller.nix { inherit pkgs nix2container; };
  kustomizeController = import ./kustomize-controller.nix { inherit pkgs nix2container; };
  notificationController = import ./notification-controller.nix { inherit pkgs nix2container; };
  sourceController = import ./source-controller.nix { inherit pkgs nix2container; };

  buildAllControllers = pkgs.writeShellScriptBin "flux-all" ''
    #!/usr/bin/env bash
    set -euo pipefail

    echo "--- Building and loading all Flux controllers ---"

    echo "Building helm-controller..."
    nix build .#flux-helm-controller.copyToDockerDaemon -L

    echo "Building kustomize-controller..."
    nix build .#flux-kustomize-controller.copyToDockerDaemon -L

    echo "Building source-controller..."
    nix build .#flux-source-controller.copyToDockerDaemon -L

    echo "Building notification-controller..."
    nix build .#flux-notification-controller.copyToDockerDaemon -L

    echo "All controllers built successfully!"
  '';

in
{

  controllers = {
    helm = helmController;
    kustomize = kustomizeController;
    notification = notificationController;
    source = sourceController;
  };

  all = buildAllControllers;

}
