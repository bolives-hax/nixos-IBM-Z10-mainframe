{
  inputs = {
    nixpkgs = {
      #url = "path:/home/flandre/nixpkgs-p";
      #url = "path:/tmp/nixpkgs-p";
      url = "github:bolives-hax/nixpkgs/zz"; # lxc-image-fixes";
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
          ./modules/nixpkgs-fixes.nix
          ./modules/disabled.nix
          ./modules/personalisation.nix
          ./modules/host_platform.nix
          ./modules/common.nix
          ./modules/network.nix


          #./modules/hydra.nix

	  # do we want these profiles for all releases?
          #"${nixpkgs}/nixos/modules/profiles/headless.nix"
          "${nixpkgs}/nixos/modules/profiles/minimal.nix"
        ];
      };
    in
    {
      packages.s390x-linux = let mkLxc = format: nixos-generators.nixosGenerate ({
        inherit (sys) system;
        specialArgs = sys.specialArgs;
        modules = sys.modules;
	inherit format;
      }); in {
	lxcImage = mkLxc "lxc";
	lxcImageMetadata = mkLxc "lxc-metadata";
	tarball = (nixpkgs.lib.nixosSystem {
		inherit (sys) system specialArgs;
		modules = sys.modules ++ [
          		# make a tarball
			./modules/tarball.nix
		];
	}).config.system.build.tarball;
	iso = (nixpkgs.lib.nixosSystem {
		inherit (sys) system specialArgs;
		modules = sys.modules ++ [

			#{ boot.kernelParams = [ "boot.debug1devices" "boot.shell_on_fail" ]; }
	  		# only include this in the iso temporarily
	  		#./modules/child-system.nix

  			"${nixpkgs}/nixos/modules/installer/cd-dvd/iso-image-s390x.nix"
			# IBMs buildservers don't natively support nix
			# ( afterall they gave me access to ... support nix ... )
			# but allow me to use kvm, thus make sure to include lxc to allow using
			# multiple nixos containers in there <which can be build like above>
          		./modules/lxc.nix
			./modules/iso.nix
		];
	}).config.system.build.isoImage;
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
