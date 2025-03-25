{ ... }:

{
  programs.plasma = {
    enable = true;
    powerdevil.AC = {
      autoSuspend.action = "nothing";
      powerButtonAction = "shutDown";
      powerProfile = "performance";
    };
    kscreenlocker.autoLock = false;
  };
}
