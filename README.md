# Dependencies

- [Nix](https://nixos.org/nix/)
- [Direnv](https://direnv.net/)

Requires experimental features of nix to be enabled.

```bash
mkdir -p ~/.config/nix && grep -q "^experimental-features = nix-command flakes$" ~/.config/nix/nix.conf || echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

## Init Ephemeral Dev Shell

<!-- markdownlint-disable MD036 -->

_With direnv_

```bash
direnv allow
```

_Without direnv_

<!-- markdownlint-enable MD036 -->

```bash
nix develop
```

## Format

```bash
nix fmt
```

## Purpose

I wanted to create a repo that is public and open source that contains the patched versions of the software I use in my Kubernetes deployments. I leverage the nix programming language to declaratively build these docker images.

## Goals

- 0 CVEs
- Small (Size really matters in the work that I do)
- Declaritive build process with complete reproducibility

## Crossplane

- build

```bash
nix run .#crossplane.copyToDockerDaemon -L
```

## Dragonfly Operator

- build

```bash
nix run .#dragonfly-operator.copyToDockerDaemon -L
```

## External DNS

- build

```bash
# Run without sandbox otherwise tests will fail
nix run .#external-dns.copyToDockerDaemon
```

## Flux Helm Controller

- build

```bash
nix run .#flux-helm-controller.copyToDockerDaemon -L
```

## Flux Kustomize Controller

- build

```bash
nix run .#flux-kustomize-controller.copyToDockerDaemon -L
```

## Flux Notification Controller

- build

```bash
nix run .#flux-notification-controller.copyToDockerDaemon -L
```

## Flux Source Controller

- build

```bash
nix run .#flux-source-controller.copyToDockerDaemon -L
```

## Flux All

- build

```bash
# Build all 4 Flux Controllers with one command
nix run .#flux-all -L
```
