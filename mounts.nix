{ config, pkgs, ... }:

{
  fileSystems."/mnt/media" = {
    device = "//192.168.1.217/media";
    fsType = "cifs";
    options = [ "username=rob" "password=W79HYNsP9oe3KbwENNT" "x-systemd.automount" "noauto" ]; 
  };

  fileSystems."/mnt/capture" = {
    device = "//192.168.1.217/capture";
    fsType = "cifs";
    options = [ "username=rob" "password=W79HYNsP9oe3KbwENNT" "x-systemd.automount" "noauto" ]; 
  };
}
