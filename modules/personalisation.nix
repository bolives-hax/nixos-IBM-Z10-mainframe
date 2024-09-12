{ pkgs, ... }:
{

  users.users.flandre = {
    group = "flandre";
    extraGroups = [ "wheel" ];
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIElUjkC47A1SocplhjDrfoMdIiL8XS+aZAq18MEpY4/M flandre@nixos"
    ];
  };
  security.sudo.wheelNeedsPassword = false;
  users.groups.flandre = { };
  services.getty.autologinUser = "flandre";

  environment.defaultPackages = with pkgs; [
    lix
    gcc
    rustc
    cargo
    kexec-tools
    neofetch
    netcat-gnu
    # V for testing kvm speed (sadly needs wayland/glsl etc and that fails)
    #stress-ng
    htop
    tmux
    xxd
    git
    psmisc
    file
    vim
    #qemu
    monero-cli
  ];
  #services.xserver.windowManager.dwm.enable = true;
}
