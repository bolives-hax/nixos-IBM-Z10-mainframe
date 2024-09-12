{
  nix = {
    settings = {
      cores = 0;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };

  nixpkgs.flake.setNixPath = true;

  services.openssh = {
    enable = true;
    ports = [ 2222 ];
  };
}
