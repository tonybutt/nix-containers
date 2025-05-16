{ pkgs, nix2container, ... }:
let
  version = "1.5.1";
  kustomize-controller-bin = pkgs.buildGoModule {
    pname = "kustomize-controller";
    inherit version;

    patches = [ ./patches/kustomize-controller-update.patch ];
    overrideModAttrs = {
      patches = [ ./patches/kustomize-controller-update.patch ];
    };

    src = pkgs.fetchFromGitHub {
      owner = "fluxcd";
      repo = "kustomize-controller";
      rev = "v${version}";
      hash = "sha256-gKxeEq0ysLdUrgWGQQG/ZUXyibDwwKKe54z/MOhdOII=";
    };

    vendorHash = "sha256-hi14QgVm6KE77dbE6eQ3i49KDB1IgQgrL33BPY7F2/o=";

    excludedPackages = [
      "api/"
    ];

    postInstall = ''
      mkdir -p $out/usr/bin
      mv $out/bin/kustomize-controller $out/usr/bin
      rm -rf $out/bin
    '';

    doCheck = false;

    env.CGO_ENABLED = 0;

    meta = with pkgs.lib; {
      description = "The GitOps Toolkit Kustomize reconciler ";
      homepage = "https://github.com/fluxcd/kustomize-controller";
      license = licenses.asl20;
      maintainers = [ "josh" ];
    };
  };
in

nix2container.packages.${pkgs.system}.nix2container.buildImage {
  name = "kustomize-controller";
  tag = "v${version}";
  copyToRoot = [
    pkgs.cacert
  ];
  layers = [
    (nix2container.packages.${pkgs.system}.nix2container.buildLayer {
      copyToRoot = [ kustomize-controller-bin ];
      perms = [
        {
          path = kustomize-controller-bin;
          regex = ".*";
          uid = 65534;
          gid = 65534;
          uname = "nonroot";
          gname = "nonroot";
        }
      ];
      metadata = {
        created_by = "nix2container";
        author = "joshtaylor";
      };
    })
  ];
  config = {
    user = "65534";
    entrypoint = [ "/usr/bin/kustomize-controller" ];
    labels = {
      "org.opencontainers.image.title" = "kustomize-controller";
    };
  };
}
