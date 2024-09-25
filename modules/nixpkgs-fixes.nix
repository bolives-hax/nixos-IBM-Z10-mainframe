{  libfuse-fixes, ... }:
{
  nixpkgs = {
    overlays = [
      # TODO why was this needed again?
      (self: super: { makeModulesClosure = x: super.makeModulesClosure (x // { allowMissing = true; }); })
      # libfuse is unavoidable as it seems but it (TODO check wbu native) doesn't seem to work
      # when cross compiling from x86_64 to s390x
      (final: prev: { fuse = prev.fuse.overrideAttrs (n: o: { src = libfuse-fixes.outPath; }); })
      # this is needed as libressl upright dropped s390x support and nc would come from libressl
      (final: prev: { libressl = prev.openssl // ({ nc = prev.netcat-gnu; }); })
    ];
    config.allowUnsupportedSystem = true;
  };
}
