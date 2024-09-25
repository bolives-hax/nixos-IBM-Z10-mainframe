{nixpkgs,...}: {
  environment.etc.s = {
	source  = (nixpkgs.lib.nixosSystem {
    	system = "s390x-linux";
    	modules = [
          ./nixpkgs-fixes.nix
          ./host_platform.nix
    	  {
    	    boot.kernelParams = [
    	      #"lol"
    	    ];
    	    #system.stateVerison = "24.0";
    	    boot.loader.zipl = {
    	      enable = true;
    	      device = "/dev/dasddd";
    	    };
    	    boot.loader.grub.enable = false;
    	    fileSystems."/" = {
    	      fsType = "tmpfs";
    	    };
    	  }
    	];
     }).config.system.build.toplevel;
  };
}
