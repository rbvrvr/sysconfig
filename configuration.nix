# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      <agenix/modules/age.nix>
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "nl_NL.UTF-8";
    LC_IDENTIFICATION = "nl_NL.UTF-8";
    LC_MEASUREMENT = "nl_NL.UTF-8";
    LC_MONETARY = "nl_NL.UTF-8";
    LC_NAME = "nl_NL.UTF-8";
    LC_NUMERIC = "nl_NL.UTF-8";
    LC_PAPER = "nl_NL.UTF-8";
    LC_TELEPHONE = "nl_NL.UTF-8";
    LC_TIME = "nl_NL.UTF-8";
  };

  # Enable login+sudo using physical cryptographic key
  security.pam = {
    u2f.enable = true;
    services.login.u2fAuth = true;
    services.sudo.u2fAuth = true;
    services.hyprlock.enable = true;
  };

  # Add SSH host key pair
  services.openssh = {
    enable = true;
    hostKeys = [
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }  
    ];
  };

  # Read the secrets file containing SAMBA credentials
  # Can be decrypted using the right SSH host private key
  age.secrets.rob-truenas.file = ./secrets/rob-truenas.age;

  # Mount capture share, using SAMBA credentials
  fileSystems."/mnt/capture" = {
    device = "//192.168.1.217/capture";
    fsType = "cifs";
    options = [ "credentials=${config.age.secrets.rob-truenas.path}" "x-systemd.automount" "noauto" ]; 
  };

  # Mount media share, using SAMBA credentials
  fileSystems."/mnt/media" = {
    device = "//192.168.1.217/media";
    fsType = "cifs";
    options = [ "credentials=${config.age.secrets.rob-truenas.path}" "x-systemd.automount" "noauto" ]; 
  };

 # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  # Removing this will do some harm to my hyprpanel system and make login ugly.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Enable Hyprland
  services.displayManager.defaultSession = "hyprland";
  programs.hyprland.enable = true;  # enable compositor
  services.hypridle.enable = true;  # idle mgmt daemon, for hyprlock

  # Enable fish terminal
  programs.fish.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "gb";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "uk";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable Flatpak
  services.flatpak.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Lock screen when Yubikey is rmoved
  # This behaviour also depends on hypridle, hyprlock and their dotfiles
  services.udev.extraRules = ''
    ACTION=="remove", ENV{ID_BUS}=="usb", ENV{ID_MODEL_ID}=="0407", ENV{ID_VENDOR_ID}=="1050", RUN+="${pkgs.systemd}/bin/loginctl lock-sessions"
  '';

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.rob = {
    isNormalUser = true;
    description = "Rob";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.fish;
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;
 
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    wget
    hyprland   # compositor
    kitty      # terminal
    nwg-look   # GTK settings editor
    rofi       # application launcher
    hyprpanel  # panel for hyprland
    hyprlock   # lock screen for hyprland
    hyprpaper  # wallpaper
    cifs-utils # samba mount
    obsidian
    bitwarden-desktop
    tutanota-desktop
    libreoffice
    blender
    krita
    geary
    mullvad-vpn
    fortune    # random messages shown in kitty (see config)
    stow       # manage dotfiles
    git        # version control for config & dotfiles
    vlc
    (callPackage <agenix/pkgs/agenix.nix> {})  # agenix command
 ];

  fonts.packages = with pkgs; [
    fira-code
    fira-code-symbols
    nerd-fonts.fira-code
    jetbrains-mono
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
