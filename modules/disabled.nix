{ nixpkgs, ... }:
{
  /*
    disabledModules = [
      "${nixpkgs}/nixos/modules/profiles/all-hardware.nix"
      "${nixpkgs}/nixos/modules/profiles/base.nix"
    ];
  */

  # disable useless software
  xdg.icons.enable = false;
  xdg.mime.enable = false;
  xdg.sounds.enable = false;
}
