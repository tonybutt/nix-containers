{ pkgs, nix2container, ... }:
let
  version = "0.16.1";
  external-dns-bin = pkgs.buildGoModule {
    pname = "external-dns";
    inherit version;

    patches = [ ./deps-update.patch ];
    overrideModAttrs = {
      patches = [ ./deps-update.patch ];
    };

    src = pkgs.fetchFromGitHub {
      owner = "kubernetes-sigs";
      repo = "external-dns";
      rev = "v${version}";
      hash = "sha256-5SoqRYKS506vVI8RsuAGrlKR/6OuuZkzO5U8cAMv51I=";
    };

    vendorHash = "sha256-GqSrmJ5I8lDgMGYlqiWlf++PbjM3aqBNAfUesNUsSDo=";

    ldflags = [
      "-s -w -X sigs.k8s.io/external-dns/pkg/apis/externaldns.Version=v${version}"
    ];

    postInstall = ''
      mkdir -p $out/usr/bin
      mv $out/bin/external-dns $out/usr/bin
      rm -rf $out/bin
    '';

    doCheck = false;

    env.CGO_ENABLED = 0;

    meta = with pkgs.lib; {
      description = "ExternalDNS synchronizes exposed Kubernetes Services and Ingresses with DNS providers";
      homepage = "https://github.com/kubernetes-sigs/external-dns";
      license = licenses.mit;
      maintainers = [ "cheeks" ];
    };
  };
in

nix2container.packages.${pkgs.system}.nix2container.buildImage {
  name = "registry.gamewarden.io/demo-test/external-dns";
  tag = "v${version}";
  copyToRoot = [
    pkgs.cacert
  ];
  layers = [
    (nix2container.packages.${pkgs.system}.nix2container.buildLayer {
      copyToRoot = [ external-dns-bin ];
      perms = [
        {
          path = external-dns-bin;
          regex = ".*";
          uid = 65532;
          gid = 65532;
          uname = "nonroot";
          gname = "nonroot";
        }
      ];
      metadata = {
        created_by = "nix2container";
        author = "tonybutt";
      };
    })
  ];
  config = {
    user = "65532";
    cmd = [ "--help" ];
    entrypoint = [ "/usr/bin/external-dns" ];
    labels = {
      "org.opencontainers.image.title" = "external-dns";
    };
  };
}
