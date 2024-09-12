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
    nixos-generators = {
	url = "github:nix-community/nixos-generators";
	inputs.nixpkgs.follows = "nixpkgs";
   };
  };
  outputs =
    {
      self,
      nixpkgs,
      libfuse,
      nixos-generators
    }: let
	sys =  {
	  specialArgs = { npkgs = nixpkgs; };
          system = "s390x-linux";
          modules = [
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
                  "${nixpkgs}/nixos/modules/profiles/headless.nix"
                  "${nixpkgs}/nixos/modules/profiles/minimal.nix"
                  "${nixpkgs}/nixos/modules/installer/cd-dvd/iso-image-s390x.nix"
                ];



                # TODO now that the mk-s390-image is fixed we can remove this right?
                #boot.initrd.compressor = "cat";
                # disable useless software
                xdg.icons.enable = false;
                xdg.mime.enable = false;
                xdg.sounds.enable = false;
              }
            )
          ];
        };
    in {
      packages.s390x-linux.lxc_image = nixos-generators.nixosGenerate ( {
	inherit (sys) system;
	specialArgs = sys.specialArgs  // {
		pkgs = import nixpkgs {
			localSystem = {
				gcc.arch = "z10";
				inherit (sys) system;
			};
			overlays = [
                  		# TODO why was this needed again?
                  		(self: super: { makeModulesClosure = x: super.makeModulesClosure (x // { allowMissing = true; }); })
                  		# libfuse is unavoidable as it seems but it (TODO check wbu native) doesn't seem to work
                  		# when cross compiling from x86_64 to s390x
                  		(final: prev: { fuse = prev.fuse.overrideAttrs (n: o: { src = libfuse.outPath; }); })
                  		# this is needed as libressl upright dropped s390x support and nc would come from libressl
                  		(final: prev: { libressl = prev.openssl // ({ nc = prev.netcat-gnu; }); })
			];
		};
	};
	modules = sys.modules ++ [
		{
			nixpkgs.hostPlatform.gcc.arch = "z10"; # "s390x-linux";
		}
		#./modules/lxc.nix
	];
	#pkgs = (import nixpkgs { inherit (sys) system; });
	#format = "lxc-metadata";
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
