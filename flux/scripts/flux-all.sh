#!/usr/bin/env bash
set -euo pipefail

echo "--- Building and loading all Flux controllers ---"

echo "Building helm-controller..."
nix run .#flux-helm-controller.copyToDockerDaemon -L

echo "Building kustomize-controller..."
nix run .#flux-kustomize-controller.copyToDockerDaemon -L

echo "Building source-controller..."
nix run .#flux-source-controller.copyToDockerDaemon -L

echo "Building notification-controller..."
nix run .#flux-notification-controller.copyToDockerDaemon -L

echo "All controllers built successfully!"
