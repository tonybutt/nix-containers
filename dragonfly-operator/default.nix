{ pkgs, nix2container, ... }:
let
  version = "1.1.11";
  operator = pkgs.buildGoModule {
    pname = "dragonfly-operator";
    inherit version;

    patches = [ ./deps-update.patch ];
    overrideModAttrs = {
      patches = [ ./deps-update.patch ];
    };

    src = pkgs.fetchFromGitHub {
      owner = "dragonflydb";
      repo = "dragonfly-operator";
      rev = "v${version}";
      hash = "sha256-7VpYKg/VsMDhLzHTW93+02MzgTZHRHZwL3uHZnQPOS0=";
    };

    vendorHash = "sha256-D6Az6izatEjxN44Kju+HBISHqoD7x/bckpDA7Dj3OT4=";

    env.CGO_ENABLED = 0;

    postInstall = ''
      mkdir -p $out/usr/bin
      mv $out/bin/cmd $out/usr/bin/manager
      rm -rf $out/bin
    '';

    doCheck = false;

    meta = with pkgs.lib; {
      description = "A Kubernetes operator to install and manage Dragonfly instances";
      homepage = "https://github.com/dragonflydb/dragonfly-operator";
      license = licenses.asl20;
    };
  };
in

nix2container.packages.${pkgs.system}.nix2container.buildImage {
  name = "registry.gamewarden.io/demo-test/operator";
  tag = "v${version}";
  copyToRoot = [
    pkgs.cacert
  ];
  layers = [
    (nix2container.packages.${pkgs.system}.nix2container.buildLayer {
      copyToRoot = [ operator ];
      perms = [
        {
          path = operator;
          regex = ".*";
          uid = 65532;
          gid = 65532;
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
    user = "65532";
    cmd = [ "--help" ];
    entrypoint = [ "/usr/bin/manager" ];
    labels = {
      "org.opencontainers.image.title" = "operator";
    };
  };
}
