{npkgs,...}: {
	services.nginx = {
		enable = true;
	};
	#services.hydra = {
	#	enable = false; #true;
	#};


	environment.etc.tst = let nixpkgs = npkgs;
	in {
		source = (import nixpkgs {
		    localSystem = {
    			    system = "x86_64-linux";
    		    };
    			# building FOR
    			crossSystem = {
    			    gcc.arch = "z10";
    			    system = "s390x-linux";
    			};
		}).haskell.compiler.native-bignum.ghc948;
	};
}
