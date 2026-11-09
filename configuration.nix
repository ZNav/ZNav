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
      echo " htb.u    ~ opens up openvpn connection to htb"
      echo " htb.d    ~ closes down open connection to htb"
      echo " on.x/off ~ any service listed can be used in place of x"
      echo ""
      echo " services ~ jellyfin, immich, qbittorrent, minecraft-server, openvpn-htb"
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

#config
  nixpkgs.config.allowUnfree = true;
  time.timeZone = "America/New_York";
  services.xserver.xkb.layout = "us";
  services.xserver.videoDrivers = [ "amdgpu" ];
  hardware.graphics.enable = true;


  # user - config
  users.defaultUserShell = pkgs.zsh;
  users.users.sasha = {
    isNormalUser = true;
    useDefaultShell = true;
    extraGroups = [ "wheel" "data" ];
    homeMode = "0755";
    packages = with pkgs; [ ];
  };

  # service groups - config
  users.users.qbittorrent.extraGroups = [ "data" ];
  users.users.jellyfin.extraGroups = [ "data" "video" "render" ];
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
      "htb.u" = "sudo systemctl start openvpn-htb";
      "htb.d" = "sudo systemctl stop openvpn-htb";
    };
    interactiveShellInit = ''
      gnomepage
    '';
  };

  # file management - arc
  systemd.tmpfiles.rules = [
    "d /data 0775 sasha data -"
    "d /data/pictures 0775 sasha data -"
    "d /data/movies 0775 sasha data -"
    "d /data/shows 0775 sasha data -"
    "d /data/music 0775 sasha data -"
    "d /data/books 0775 sasha data -"
    "d /data/unsorted 0775 sasha data -"
    "d /data/files 0775 sasha data -"
    "d /data/.Private 0775 sasha data -"
    "d /data/videos 0775 sasha data -"
  ];

  # packages - arc
  environment.systemPackages = with pkgs; [
    gnomepage # util
    neovim # util
    wget # utilities
    tree # utilities
    eza # utilities
    openvpn # networking
    git # version control
    fastfetch # stats
    ghostty # terminal
    cmus # tui audio player
    ranger # tui file explorer
    cbonsai # screensaver
    python3 # python
    jellyfin-ffmpeg # jellyfin transcoding
    rustdesk # remote desktop

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
    8080 # qbitt
    2283 # immich
    8096 # jellyfin
    25565 # minecraft
    1194 # openvpn
    8123 # homeassistant
    9090 # cockpit
  ];
  networking.firewall.allowedUDPPorts = [ 
    1194 # openvpn
  ]; 
  networking.firewall.checkReversePath = "loose";
  networking.networkmanager.enable = true;
  networking.hostName = "sasha";

  #htb openvpn
  services.openvpn.servers.htb = {
    autoStart = false;
    config = "/data/.Private/htb.ovpn";
    updateResolvConf = true;
  };

# Services

  # minecraft - service
  services.minecraft-server = {
    enable = true;
    eula = true;
    jvmOpts = "-Xms4096M -Xmx4096M";
    declarative = true;
    serverProperties = {
      "server-port" = 25565;
    };
  };

  # qbit - service
  services.qbittorrent = {
    enable = true;
  };

  # photo browser - service
  services.immich = {
    enable = true;
    host = "0.0.0.0";
  };

  # media server - service
  services.jellyfin = {
    enable = true;
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
      http = {
        use_x_forwarded_for = true;
	trusted_proxies = [ "127.0.0.1" "::1" ];
      };
    };
  };

  # cockpit - service
  services.cockpit.enable = true;

#util

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
 
