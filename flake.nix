{
  inputs = {
    nixpkgs = {
      #url = "path:/home/flandre/nixpkgs-p";
      url = "/tmp/nixpkgs-p";
    };
    libfuse = {
      url = "github:bolives-hax/libfuse/s390x-fix";
      flake = false;
    };
  };
  outputs =
    {
      self,
      nixpkgs,
      libfuse,
    }:
    {
      nixosConfigurations = {
        z10 = nixpkgs.lib.nixosSystem {
          system = "s390x-linux";
          modules = [
            # make a tarball
            ./modules/make-tarball.nix
            ./modules/personalisation.nix
            ./host_platform.nix
            (
              {
                config,
                pkgs,
                lib,
                ...
              }:
              {
                boot = {
                  loader = {
                    grub.enable = lib.mkDefault false;
                    # V TODO 
                    generic-extlinux-compatible.enable = lib.mkDefault true;
                  };
                };
              }
            )
            (
              { pkgs, ... }:
              {
                nixpkgs.overlays = [
                  # TODO why was this needed again?
                  (self: super: { makeModulesClosure = x: super.makeModulesClosure (x // { allowMissing = true; }); })
                  # libfuse is unavoidable as it seems but it (TODO check wbu native) doesn't seem to work
                  # when cross compiling from x86_64 to s390x
                  (final: prev: { fuse = prev.fuse.overrideAttrs (n: o: { src = libfuse.outPath; }); })
                  # this is needed as libressl upright dropped s390x support and nc would come from libressl
                  (final: prev: { libressl = prev.openssl // ({ nc = prev.netcat-gnu; }); })
                ];
                nixpkgs.config.allowUnsupportedSystem = true;

                imports = [
                  #"${nixpkgs}/nixos/modules/profiles/headless.nix"
                  "${nixpkgs}/nixos/modules/profiles/minimal.nix"
                  "${nixpkgs}/nixos/modules/installer/cd-dvd/iso-image-s390x.nix"
                ];

                boot.loader.grub = {
                  enable = false;
                };

                disabledModules = [
                  "${nixpkgs}/nixos/modules/profiles/all-hardware.nix"
                  "${nixpkgs}/nixos/modules/profiles/base.nix"
                ];

                # TODO now that the mk-s390-image is fixed we can remove this right?
                boot.initrd.compressor = "cat";
                # disable useless software
                xdg.icons.enable = false;
                xdg.mime.enable = false;
                xdg.sounds.enable = false;
              }
            )
          ];
        };
      };
    };
}
