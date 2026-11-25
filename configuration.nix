{
  config,
  lib,
  pkgs,
  ...
}:

let

  # gnomepage tui - util
  gnomepage = pkgs.writeShellApplication {
    name = "gnomepage";
    runtimeInputs = with pkgs; [ fastfetch cbonsai ncurses ];
    text = ''
      clear
      cbonsai -p
      echo "hello sasha :p"
      echo ""
      echo "          ~ some options for my favorite baby bing"
      echo " cfig     ~ opens configuration.nix in nvim"
      echo " wrkspc   ~ changes dirs to where configuration.nix is"
      echo " ll       ~ list files"
      echo " filecnt  ~ count files in dir"
      echo " ranger   ~ file manager"
      echo " cmus     ~ music player"
      echo " rib      ~ run it back runs sudo nixos-rebuild switch"
      echo " gitbs    ~ adds configuration.nix"
      echo " heave    ~ rib then gitbs"
      echo " tidy     ~ source zsh"
      echo " scrub    ~ collect nix garbage and source zsh"
      echo " on.x/off ~ any service listed can be used in place of x"
      echo ""
      echo " services ~ jellyfin, immich, minecraft-server"
      echo " gp       ~ this page :o"
      echo ""
    '';
  };

in

{
  imports = [
    ./hardware-configuration.nix
  ];

#initialization
  # bootloader - util
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  documentation.enable = false; # disabling due to python crash

  #mount external ssd for file integreity check on both ends
  fileSystems."/data/external" = {
    device = "/dev/disk/by-uuid/5639c41b-9d0c-4149-b77f-b0b947a36cbe";
    fsType = "ext4";
    options = [ "nofail" ];
  };

#config
  nixpkgs.config.allowUnfree = true;
  time.timeZone = "America/New_York";
  services.xserver.xkb.layout = "us";
  services.xserver.videoDrivers = [ "amdgpu" ];


  # user - config
  users.defaultUserShell = pkgs.zsh;
  users.users.sasha = {
    isNormalUser = true;
    useDefaultShell = true;
    extraGroups = [ "wheel" "data" "render" "video" ];
    homeMode = "0755";
    packages = with pkgs; [ ];
  };

  # service groups - config
  users.extraGroups.data = {};
  users.users.jellyfin.extraGroups = [ "data" "video" "render" "wheel"];
  users.users.immich.extraGroups = [ "data" ];

  # commands - config
  programs.zsh = {
    enable = true;
    shellAliases = {
      ".." = "cd ..";
      "ll" = "ls -lah";
      "gp" = "gnomepage";
      "filecnt" = "ls -1A | wc -l";
      "wrkspc" = "cd ~ && cd ../../etc/nixos";
      "cfig" = "wrkspc && nvim configuration.nix";
      "rib" = "wrkspc && sudo nixos-rebuild switch";
      "gitbs" = "git add configuration.nix";
      "heave" = "rib && gitbs";
      "commit" = "git commit -m ";
      "tidy" = "cd ~ && source ~/.zshrc";
      "scrub" = "tidy && sudo nix-collect-garbage";
      "gs" = "'+set number'";
      "nvim" = "nvim '+set number'";
      "st" = "systemctl-tui";
    };
    interactiveShellInit = ''
      gnomepage
    '';
  };

  # file management - arc
  systemd.tmpfiles.rules = [
    "d /data 0775 data data -"
    "d /data/encoded-video/ 0755 data data -"
    "d /data/external 0775 data data -"
    "d /data/pictures 0775 data data -"
    "d /data/unsorted 0775 data data -"
    "d /data/.Private 0775 root data -"
  ];

  # packages - arc
  environment.systemPackages = with pkgs; [
    gnomepage # util
    neovim # util
    wget # utilities
    tree # utilities
    eza # utilities
    git # version control
    fastfetch # stats
    ghostty # terminal
    cmus # tui audio player
    ranger # tui file explorer
    cbonsai # screensaver
    python3 # python
    jellyfin-ffmpeg # jellyfin transcoding
    htop # stats
    systemctl-tui # monitoring
    zfs
    fdupes
    wiper

    #hacking
    nmap
    metasploit
    john
    hashcat
    seclists
  ];

  # ssh - arc
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      KbdInteractiveAuthentication = true;
      PermitRootLogin = "yes";
      AllowUsers = [ "sasha" ];
    };
  };

  # firewall - arc
  networking.firewall.allowedTCPPorts = [
    22 # ssh
    2283 # immich
    8096 # jellyfin
    443 # tailscale
    9696 # prowlarr
    3389 # rdp
  ];
  networking.firewall.checkReversePath = "loose";
  networking.networkmanager.enable = true;
  networking.hostName = "sasha";


  #tailscale - arc
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";
  };


# Services

  # gnomerdp - service
  services.gnome.gnome-remote-desktop.enable = true;

  # immich - service
  services.immich = {
    enable = true;
    host = "0.0.0.0";
  };

  # jellyfin - service
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      libva-vdpau-driver
      mesa
    ];
  };

  services.jellyfin = {
    enable = true;
    hardwareAcceleration = {
      enable = true;
      type = "vaapi";
      device = "/dev/dri/renderD128";
    };
  };

  # home assistant - service
  services.home-assistant = {
    enable = true;
    extraComponents = [
      "default_config"
      "systemmonitor"
      "command_line"
    ];
    config = {
    mobile_app = {};
    };
  };

  # prowlarr - service
  services.prowlarr = {
    enable = true;
  };

#util

  # desktop manager - util
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # power management - util
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchDocked = "ignore";
    HandleLidSwitchExternalPower = "ignore";
  };

  systemd.targets = {
    sleep.enable = false;
    suspend.enable = false;
    hibernate.enable = false;
    hybrid-sleep.enable = false;
  };
  systemd.sleep.settings = {
    Sleep = {
      AllowSuspend = "no";
      AllowHibernation = "no";
      AllowHybridSleep = "no";
      AllowSuspendThenHibernate = "no";
    };
  };
  programs.dconf.enable = true;
  programs.dconf.profiles.user.databases = [
    {
      settings = {
        "org/gnome/settings-daemon/plugins/power" = {
          sleep-inactive-ac-type = "nothing";
          sleep-inactive-ac-timeout = lib.gvariant.mkUint32 0;
        };
      };
    }
  ];
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="pci", DRIVER=="pcieport", ATTR{power/wakeup}="disabled"
  '';


# DO NOT TOUCH BELOW THIS
  system.stateVersion = "26.05";
}
