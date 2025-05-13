{ pkgs, nix2container, ... }:
let
  external-dns-bin = pkgs.buildGoModule rec {
    pname = "external-dns";
    version = "0.16.1";

    patches = [ ./deps-update.patch ];
    postPatch = ''
      export GOCACHE=$TMPDIR/go-cache
      export GOPATH="$TMPDIR/go"
      go mod tidy
      go mod vendor
    '';

    src = pkgs.fetchFromGitHub {
      owner = "kubernetes-sigs";
      repo = "external-dns";
      rev = "v${version}";
      hash = "sha256-5SoqRYKS506vVI8RsuAGrlKR/6OuuZkzO5U8cAMv51I=";
    };
    vendorHash = "sha256-BEHtKKbUKEuP75jt95K6X9jL8+pyVdcG1oClPL/URIQ=";

    configurePhase = ''
      runHook preConfigure
      export GOCACHE=$TMPDIR/go-cache
      export GOPATH="$TMPDIR/go"
      export GOPROXY=off
      export GOSUMDB=off
      cd "$modRoot"
      runHook postConfigure
    '';
    ldflags = [
      "-s -w -X sigs.k8s.io/external-dns/pkg/apis/externaldns.Version=v${version}"
    ];
    # Because we are patching source we have to hack
    # around the go flags to get this to build properly
    # preBuild = ''
    #   set -x
    #   export GOFLAGS=-mod=mod
    #   export GOPROXY="https://proxy.golang.org,direct"
    # '';
    postInstall = ''
      rm -rf $out/bin/flags
      rm -rf $out/bin/metrics
    '';

    env = {
      CGO_ENABLED = 0;
    };

    meta = with pkgs.lib; {
      description = "ExternalDNS synchronizes exposed Kubernetes Services and Ingresses with DNS providers";
      homepage = "https://github.com/kubernetes-sigs/external-dns";
      license = licenses.mit;
      maintainers = [ "cheeks" ];
    };
  };
in

nix2container.packages.${pkgs.system}.nix2container.buildImage {
  name = "external-dns";
  copyToRoot = [
    external-dns-bin
    pkgs.cacert
  ];
  perms = [
    {
      path = external-dns-bin;
      regex = ".*";
      uid = 1000;
      gid = 1000;
      uname = "nonroot";
      gname = "nonroot";
    }
  ];
  config = {
    entrypoint = [ "/bin/external-dns" ];
    labels = {
      testy = "mcTestterton";
    };
  };
}
