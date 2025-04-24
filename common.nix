{
  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [ "dotnet-runtime-7.0.20" ]; # for vintagestory
  };
}
