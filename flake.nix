{
  inputs = {
    nixpkgs = {
      #url = "path:/home/flandre/nixpkgs-p";
      url = "/tmp/nixpkgs-p";
    };
    libfuse-fixes = {
      url = "github:bolives-hax/libfuse/s390x-fix";
      flake = false;
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    {
      self,
      nixpkgs,
      libfuse-fixes,
      nixos-generators,
    }:
    let
      sys = {
        specialArgs = {
          inherit nixpkgs libfuse-fixes;
        };
        system = "s390x-linux";
        modules = [
          ./modules/nixpkgs.nix
          ./modules/disabled.nix
          # make a tarball
          #./modules/make-tarball.nix
          ./modules/personalisation.nix
          ./modules/host_platform.nix
          ./modules/common.nix
          ./modules/network.nix
          #./modules/hydra.nix
          #./modules/lxc.nix
          (
            { pkgs, ... }:
            {

              imports = [
                "${nixpkgs}/nixos/modules/profiles/headless.nix"
                "${nixpkgs}/nixos/modules/profiles/minimal.nix"
              ];

            }
          )
        ];
      };
    in
    {
      packages.s390x-linux.lxc_image = nixos-generators.nixosGenerate ({
        inherit (sys) system;
        specialArgs = sys.specialArgs // {
          pkgs = import nixpkgs {
            localSystem = {
              gcc.arch = "z10";
              inherit (sys) system;
            };
          };
        };
        modules = sys.modules ++ [
          {
            nixpkgs.hostPlatform.gcc.arch = "z10"; # "s390x-linux";
          }
          #./modules/lxc.nix
        ];
        format = "lxc";
      });
      nixosConfigurations = {
        z10 = nixpkgs.lib.nixosSystem {
          inherit (sys) system specialArgs;
          modules = sys.modules ++ [
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
            "${nixpkgs}/nixos/modules/installer/cd-dvd/iso-image-s390x.nix"
          ];
        };
      };
    };
}

/*
  	TODO V use a modified version of this to keep system="s390x-linux"; except
  	for rustc / s390x-tools which make use of the "lay" "opcode/operation" in llvm
  	which causes this to fail on non Z-series cpus (eg s390x as oppesed to s390x + gcc.march = "z10";

  	let
  	  pkgs = import <nixpkgs> {
  	    overlays = [
  	      (self: super: {
  	        stdenv = super.impureUseNativeOptimizations super.stdenv;
  	      })
  	    ];
  	  };
  	in
  	  pkgs.openssl
*/
