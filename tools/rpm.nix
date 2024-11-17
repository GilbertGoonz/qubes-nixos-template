{
  lib,
  fetchFromGitHub,
  nixpkgs,
  pkgs,
  nixosConfig,
}: let
  version = "4.0.6";
  rootImg = import "${nixpkgs}/nixos/lib/make-disk-image.nix" {
    inherit lib pkgs;
    config = nixosConfig.config;
    diskSize = 10240; # 10G
    partitionTableType = "hybrid";
    name = "root";
  };
in
  pkgs.stdenvNoCC.mkDerivation {
    name = "qubes-template-rpm";

    src = fetchFromGitHub {
      owner = "QubesOS";
      repo = "qubes-linux-template-builder";
      rev = "v${version}";
      hash = "sha256-ABfhqyg9PypuKWYe6yhEr99hxf7qWsYCwRyToGhPKZA=";
    };

    nativeBuildInputs = [
      pkgs.rpm
      pkgs.coreutils
      pkgs.gnutar
    ];

    dontConfigure = true;
    dontFixup = true;

    buildPhase = ''
      set -x

      mkdir -p qubeized_images/nixos
      ln -s ${rootImg}/nixos.img qubeized_images/nixos/root.img

      ln -s "appmenus_generic" appmenus
      cp template_generic.conf template.conf

      DIST=nixos ./build_template_rpm nixos
    '';

    installPhase = ''
      mkdir $out/
      mv rpm/noarch/*.rpm $out/
    '';
  }
