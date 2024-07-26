{
  inputs = {
    nixpkgs = {
      url = "github:bolives-hax/nixpkgs/s390-tools-testing-staging-cython-fix";
    };
    libfuse = {
      url = "github:bolives-hax/libfuse/s390x-fix";
      flake = false;
    };
  };
  outputs = { self, nixpkgs, libfuse }: {
    nixosConfigurations = {
      z10 = nixpkgs.lib.nixosSystem {
        system = "s390x-linux";
        modules = [
          ({ config, pkgs, lib, ... }: {
            boot = {
              loader = {
                grub.enable = lib.mkDefault false;
                generic-extlinux-compatible.enable = lib.mkDefault true;
              };
              kernelPackages = lib.mkDefault
                (pkgs.callPackage ./kernel_packages.nix {
                  inherit (config.boot) kernelPatches;
                });
            };
          })
          ({ pkgs, ... }: {
            nixpkgs.overlays = [
              (self: super: {
                makeModulesClosure = x:
                  super.makeModulesClosure (x // { allowMissing = true; });
              })
              (final: prev: {
                fuse =
                  prev.fuse.overrideAttrs (n: o: { src = libfuse.outPath; });
              })
              (final: prev: {
                libressl = prev.openssl // ({ nc = prev.netcat-gnu; });
              })
              /* (final: prev: {
                  sway = prev.sway.override (  {
                   isNixOS = false;
                   enableXWayland = false;
                   });
                 })
              */
            ];
            nixpkgs.config.allowUnsupportedSystem = true;
            nixpkgs.hostPlatform.system = "s390x-linux";
            nixpkgs.buildPlatform.system =
              "x86_64-linux"; # If you build on x86 other wise changes this.
            nixpkgs.hostPlatform.linux-kernel = {
              target = "bzImage";
              name = "s390-baka";
              autoModules = false;
              baseConfig = "defconfig"; # "minimal_s390x_defconfig";
            };
            # ... extra configs as above
            #services.xserver.enable = true;

            imports = [
              "${nixpkgs}/nixos/modules/profiles/headless.nix"
              "${nixpkgs}/nixos/modules/profiles/minimal.nix"

            ];

            #services.nginx = {
            #	enable = true;
            #};
            environment.defaultPackages = with pkgs;
              [
                neofetch
                /* (dyalog.override {
                     allowUnfree = true;
                   })
                */
              ];
            services.xserver.windowManager.dwm.enable = true;
            boot.loader.grub = { enable = false; };
            fileSystems = { "/" = { fsType = "tmpfs"; }; };
            /* boot.loader.generic-extlinux-compatible = {
                 enable = false;
               };
            */

            # only add strictly necessary modules
            #boot.initrd.includeDefaultModules = false;
            #boot.initrd.kernelModules = [ "ext4" ];
            disabledModules = [
              "${nixpkgs}/nixos/modules/profiles/all-hardware.nix"
              "${nixpkgs}/nixos/modules/profiles/base.nix"
            ];

            # disable useless software
            #xdg.icons.enable  = false;
            #xdg.mime.enable   = false;
            #xdg.sounds.enable = false;

          })
        ];
      };
    };
  };
}
