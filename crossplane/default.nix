{ pkgs, nix2container, ... }:
let
  version = "1.20.0";
  crossplane-bin = pkgs.buildGoModule {
    pname = "crossplane";
    inherit version;

    src = pkgs.fetchFromGitHub {
      owner = "crossplane";
      repo = "crossplane";
      rev = "v${version}";
      hash = "sha256-A6HX3cTst/f/QbRHHxsB/M1wm+M+I7eEmn2Yq54fbBU=";
    };

    vendorHash = "sha256-GqEGtoDo7BeMwReUO9hOOj03qt7yuXCEwCOY2VD81Vw=";

    excludedPackages = [
      "design/"
    ];

    subPackages = [
      "cmd/crossplane"
      "cmd/crank"
    ];

    ldflags = [
      "-s -w -X=github.com/crossplane/crossplane/internal/version.version=${version}"
    ];

    postInstall = ''
      mkdir -p $out/usr/bin
      mkdir -p $out/crds
      mkdir -p $out/webhookconfigurations

      mv $out/bin/crossplane $out/usr/bin
      mv $out/bin/crank $out/usr/bin
      rm -rf $out/bin

      cp -r $src/cluster/crds/* $out/crds/
      cp -r $src/cluster/webhookconfigurations/* $out/webhookconfigurations/
    '';

    doCheck = false;

    env.CGO_ENABLED = 0;

    meta = with pkgs.lib; {
      description = "The Cloud Native Control Plane ";
      homepage = "https://github.com/crossplane/crossplane";
      license = licenses.asl20;
      maintainers = [ "joshtaylor" ];
    };
  };
in
nix2container.packages.${pkgs.system}.nix2container.buildImage {
  name = "crossplane";
  tag = "v${version}";
  copyToRoot = [
    pkgs.cacert
  ];
  layers = [
    (nix2container.packages.${pkgs.system}.nix2container.buildLayer {
      copyToRoot = [ crossplane-bin ];
      perms = [
        {
          path = crossplane-bin;
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
    entrypoint = [ "/usr/bin/crossplane" ];
    labels = {
      "org.opencontainers.image.title" = "crossplane";
    };
  };
}
