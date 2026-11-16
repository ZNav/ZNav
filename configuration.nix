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
    extraGroups = [ "wheel" "data" "docker" "render" "video" ];
    homeMode = "0755";
    packages = with pkgs; [ ];
  };

  # service groups - config
  users.extraGroups.data = {};
  users.users.jellyfin.extraGroups = [ "data" "video" "render" "wheel"];
  users.users.immich.extraGroups = [ "data" "video" "render" "wheel" "docker" ];

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
    "d /data 0775 sasha data -"
    "d /data/tank 0775 sasha data -"
    "d /data/external 0775 sasha data -"
    "d /data/pictures 0775 sasha data -"
    "d /data/unsorted 0775 sasha data -"
    "d /data/files 0775 sasha data -"
    "d /data/.Private 0775 sasha data -"
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
    seafile-shared
    seafile-client
    zfs

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
    80 # adguard
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

  # immich - service
  services.immich = {
    enable = true;
    host = "0.0.0.0";
    mediaLocation = "/data/external/pictures";
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

  #adguard - service
  services.adguardhome = {
    enable = true;
    settings = {
      http = {
        address = "0.0.0.0:3000";
      };
      dns = {
        bind_hosts = [ "0.0.0.0" ];
	port = 53;
	upstream_dns = [
	  "https://dns.quad9.net/dns-query"
	  "https://cloudflare-dns.com/dns-query"
	];
	bootstrap_dns = [ "9.9.9.9" "1.1.1.1" ];
	blocking_mode = "default";
      };
      filters = [
        {
	  name = "StevenBlack Unified";
	  url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts";
	  enabled = true;
	}
      ];
    };
  };
  services.adguardhome.mutableSettings = true;

#util

  # docker - util
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
    enableOnBoot = true;
    daemon.settings = {
      log-driver = "local";
      log-opts = { max-size = "10m"; max-file = "3"; };
    };
  };


  #homarr
  virtualisation.oci-containers.containers.homarr = {
    image = "ghcr.io/homarr-labs/homarr:v1.32";
    ports = [ "7575:7575" ];
    volumes = [
      "/tank/homarr:/app/data/configs"
      "/var/run/dbus:/var/run/dbus"   # optional: docker status widgets
    ];
  };

  # desktop manager - util
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # rustdesk - util
  services.xserver.enable = true;

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
 
