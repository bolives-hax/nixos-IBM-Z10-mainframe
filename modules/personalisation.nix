{ config, lib, pkgs, ... }:
{
  # TODO split this up in modules so our ssh key also doesn't leak into releases (it probably leaekd into the first 2 debug releases)

  users.users.flandre = {
    group = "flandre";
    extraGroups = [ "wheel" ];
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIElUjkC47A1SocplhjDrfoMdIiL8XS+aZAq18MEpY4/M flandre@nixos"
    ];
  };
users.users.root.password = "root";
  security.sudo.wheelNeedsPassword = false;
  users.groups.flandre = { };
  services.getty.autologinUser = "flandre";

  environment.defaultPackages = with pkgs; [
bcc #ebpf tracing tools
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
    
    weechat
    #links2
    wireguard-tools
    tcpdump
    psmisc
    
    
    monero-cli wownero
    # useful to see build information
    nix-top
    asciinema
    
    

    radare2
    strace
    gdb

    python3

    #julia #doens't build anymore 

    # for plotting / rendering graphiz (useful for radare2)
    #xdot


    file
    # for perf
    #ffmpeg  #fails as (covid requested)
    #yt-dlp
    xxd
    nmap
    pbzip2
    p7zip
    s390-tools
    util-linux # cfdisk
    mosh
    tshark



    sshfs

    #age
    #gnupg

    ((config.boot.kernelPackages).perf)
    fio
    iotop
    perf-tools

    lsof

   dash #fish
busybox
sysstat
sysbench

  ];
    /* moved to installer/cd-dvd/iso-image-s390x.nix
    boot.kernelPackages = pkgs.linuxPackagesFor ( pkgs.linuxPackages_latest.kernel.override {
	structuredExtraConfig = with lib.kernel; {
		EARLY_PRINTK = yes;
		CRASH_DUMP = lib.mkForce yes;
                DEBUG_INFO = yes;
                EXPERT = yes;
                DEBUG_KERNEL = yes;
		TASK_DELAY_ACCT = yes;
		IKHEADERS= yes; # bcc needs this for memleak testing

		# test if that fixes kernel
		SCLP_TTY = yes;
		SCLP_CONSOLE = yes;
		SCLP_VT220_TTY = yes;
		SCLP_VT220_CONSOLE = yes;
	};
    });  */
  #services.xserver.windowManager.dwm.enable = true;
}
