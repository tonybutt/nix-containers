{ pkgs, nix2container, ... }:
let
  version = "1.5.0";
  notification-controller-bin = pkgs.buildGoModule {
    pname = "notification-controller";
    inherit version;

    patches = [ ./patches/notification-controller-update.patch ];
    overrideModAttrs = {
      patches = [ ./patches/notification-controller-update.patch ];
    };

    src = pkgs.fetchFromGitHub {
      owner = "fluxcd";
      repo = "notification-controller";
      rev = "v${version}";
      hash = "sha256-r2cAxZQ+WsS0EUbaQlAsWTn4TbNPd/5hqad7Vw/8/x0=";
    };

    vendorHash = "sha256-10Ys+gihRftEVkjOdhC2rmFqTzeauJWEpzA1plBW1ZA=";

    excludedPackages = [
      "api/"
    ];

    postInstall = ''
      mkdir -p $out/usr/bin
      mv $out/bin/notification-controller $out/usr/bin
      rm -rf $out/bin
    '';

    doCheck = false;

    env.CGO_ENABLED = 0;

    meta = with pkgs.lib; {
      description = "The GitOps Toolkit event forwarder and notification dispatcher";
      homepage = "https://github.com/fluxcd/notification-controller";
      license = licenses.asl20;
      maintainers = [ "josh" ];
    };
  };
in

nix2container.packages.${pkgs.system}.nix2container.buildImage {
  name = "notification-controller";
  tag = "v${version}";
  copyToRoot = [
    pkgs.cacert
  ];
  layers = [
    (nix2container.packages.${pkgs.system}.nix2container.buildLayer {
      copyToRoot = [ notification-controller-bin ];
      perms = [
        {
          path = notification-controller-bin;
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
    entrypoint = [ "/usr/bin/notification-controller" ];
    labels = {
      "org.opencontainers.image.title" = "notification-controller";
    };
  };
}
