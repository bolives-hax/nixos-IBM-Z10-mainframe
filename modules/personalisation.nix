{ pkgs }:
{

  users.users.flandre = {
    group = "flandre";
    extraGroups = [ "wheel" ];
    isNormalUser = true;
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
    stress-ng # for testing kvm
    htop
    tmux
    xxd
    git
    psmisc
    file
    vim
    #qemu
  ];
  #services.xserver.windowManager.dwm.enable = true;
}
