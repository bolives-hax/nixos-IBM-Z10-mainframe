# TODO supply this over instead lib.systems.platforms.z10;
{
  nixpkgs.hostPlatform = {
    linux-kernel = {
      target = "bzImage";
      name = "s390x-defconfig";
      # TODO what does this do?
      autoModules = false;
      # TODO is this really the right config to set here?
      baseConfig = "defconfig";
    };
    gcc.arch = "z10";
  };
}
