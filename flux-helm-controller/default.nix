{ pkgs, nix2container, ... }:
let
  version = "1.2.0";
  helm-controller-bin = pkgs.buildGoModule {
    pname = "helm-controller";
    inherit version;

    patches = 
    [ ./deps-update.patch ];
    overrideModAttrs = {
      patches = [ ./deps-update.patch ];
    };

    src = pkgs.fetchFromGitHub {
      owner = "fluxcd";
      repo = "helm-controller";
      rev = "v${version}";
      hash = "sha256-knf5LTMPxsxF+181XzrxmLv5uy45ldRknwPpiELQYlg=";
    };

    vendorHash = "sha256-qzubqzWSp+9uTY5Y4mlmKiThYyQDhOCjWGkO1RZ5bLQ=";

    excludedPackages = [
      "api/"
    ];

    postInstall = ''
      mkdir -p $out/usr/bin
      mv $out/bin/helm-controller $out/usr/bin
      rm -rf $out/bin
    '';

    doCheck = false;

    env.CGO_ENABLED = 0;

    meta = with pkgs.lib; {
      description = "The GitOps Toolkit Helm reconciler, for declarative Helming";
      homepage = "https://github.com/fluxcd/helm-controller";
      license = licenses.asl20;
      maintainers = [ "josh" ];
    };
  };
in

nix2container.packages.${pkgs.system}.nix2container.buildImage {
  name = "helm-controller";
  tag = "v${version}";
  copyToRoot = [
    pkgs.cacert
  ];
  layers = [
    (nix2container.packages.${pkgs.system}.nix2container.buildLayer {
      copyToRoot = [ helm-controller-bin ];
      perms = [
        {
          path = helm-controller-bin;
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
    entrypoint = [ "/usr/bin/helm-controller" ];
    labels = {
      "org.opencontainers.image.title" = "helm-controller";
    };
  };
}
