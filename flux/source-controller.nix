{ pkgs, nix2container, ... }:
let
  version = "1.5.0";
  source-controller-bin = pkgs.buildGoModule {
    pname = "source-controller";
    inherit version;

    patches = [ ./patches/source-controller-update.patch ];
    overrideModAttrs = {
      patches = [ ./patches/source-controller-update.patch ];
    };

    src = pkgs.fetchFromGitHub {
      owner = "fluxcd";
      repo = "source-controller";
      rev = "v${version}";
      hash = "sha256-M6WWDG1TKzjf+Dgdx+Oc4zg0OlF/mJVAbW3fLZ2E8SY=";
    };

    vendorHash = "sha256-n9jv5y6Q0TZ7NAvPTNuydytg0Isp1frY11RQct7uxSE=";

    excludedPackages = [
      "api/"
    ];

    ldflags = [
      "-s -w"
    ];

    tags = [
      "netgo,osusergo,static_build"
    ];

    postInstall = ''
      mkdir -p $out/usr/bin
      mv $out/bin/source-controller $out/usr/bin
      rm -rf $out/bin
    '';

    doCheck = false;

    env.CGO_ENABLED = 0;

    meta = with pkgs.lib; {
      description = "The GitOps Toolkit source management component";
      homepage = "https://github.com/fluxcd/source-controller";
      license = licenses.asl20;
      maintainers = [ "josh" ];
    };
  };
in
{
  source-controller = nix2container.packages.${pkgs.system}.nix2container.buildImage {
    name = "source-controller";
    tag = "v${version}";
    copyToRoot = [
      pkgs.cacert
    ];
    layers = [
      (nix2container.packages.${pkgs.system}.nix2container.buildLayer {
        copyToRoot = [ source-controller-bin ];
        perms = [
          {
            path = source-controller-bin;
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
      entrypoint = [ "/usr/bin/source-controller" ];
      labels = {
        "org.opencontainers.image.title" = "source-controller";
      };
    };
  };
}
