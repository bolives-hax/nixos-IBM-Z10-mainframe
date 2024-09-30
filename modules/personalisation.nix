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
#boot.blacklistedKernelModules = [ "loop" ];
boot.initrd.extraUtilsCommands = with lib.strings; ''
        copy_bin_and_libs ${pkgs.fio}/bin/fio
        copy_bin_and_libs ${pkgs.bcc}/bin/trace
        copy_bin_and_libs ${pkgs.kexec-tools}/bin/kexec
        copy_bin_and_libs ${pkgs.strace}/bin/strace
        copy_bin_and_libs ${ ((config.boot.kernelPackages).perf)}/bin/perf
        copy_bin_and_libs ${ pkgs.patchelf }/bin/patchelf
      '';
        #copy_bin_and_libs ${pkgs.gnupg}/bin/gpg
        #copy_bin_and_libs ${pkgs.openssh}/bin/scp
#systemd.additionalUpstreamSystemUnits = ["debug-shell.service"];
#boot.initrd.systemd.additionalUpstreamUnits = [ "debug-shell.service" ];
#boot.initrd.systemd.enable = true;
systemd.services.pd = {
#description="I/O Speed Test Service";
#DefaultDependencies=no
after= [ "local-fs.target" ];
before= [ "sysinit.target" ];
wants= [ "local-fs.target" ];
 unitConfig.DefaultDependencies = false;

serviceConfig = {
	type="simple";
	ExecStart = (pkgs.stdenv.mkDerivation {
		name = "x";
		version = "0.0.1";
		src = ./../p.c;
		unpackPhase = "cp $src p.c";
		buildPhase = "$CC p.c";
		installPhase = "mkdir -p $out/bin && mv a.out $out/bin/x";
	}).outPath + "/bin/x"; # ; #pkgs.gcc.outPath + "/bin/gcc --version";
	StandardOutput="journal";
	StandardError="journal";
};

wantedBy = [ "sysinit.target" ];
};
    /* moved to installer/cd-dvd/iso-image-s390x.nix
    boot.kernelPackages = pkgs.linuxPackagesFor ( pkgs.linuxPackages_latest.kernel.override {
    version = "6.6.52";
    modDirVersion = "6.6.52";
    src = fetchTarball {
      url = "https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.6.52.tar.xz";
      sha256 = "sha256:0h92b741c602ff7i6hyndpjn8n1k06qa2pqprncd2ax9zn0k2d86";
    };
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
