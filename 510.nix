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
      echo "hello t510 :p"
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
#  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

#config
  nixpkgs.config.allowUnfree = true;
  time.timeZone = "America/New_York";
  services.xserver.xkb.layout = "us";
  hardware.graphics.enable = true;


  # user - config
  users.defaultUserShell = pkgs.zsh;
  users.users.t510 = {
    isNormalUser = true;
    useDefaultShell = true;
    extraGroups = [ "wheel" "data" ];
    homeMode = "0755";
    packages = with pkgs; [ ];
  };

  # service groups - config
  
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
    };
    interactiveShellInit = ''
      gnomepage
    '';
  };

  # file management - arc
  systemd.tmpfiles.rules = [
    "d /data 0775 t510 data -"
    "d /data/pictures 0775 t510 data -"
    "d /data/movies 0775 t510 data -"
    "d /data/shows 0775 t510 data -"
    "d /data/music 0775 t510 data -"
    "d /data/books 0775 t510 data -"
    "d /data/unsorted 0775 t510 data -"
    "d /data/files 0775 t510 data -"
    "d /data/.Private 0775 t510 data -"
    "d /data/videos 0775 t510 data -"
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
    mcrcon # minecraft administration
    freerdp # remote desktop control
    vlc

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
      AllowUsers = [ "t510" ];
    };
  };

  # firewall - arc
  networking.firewall.allowedTCPPorts = [
    22 # ssh
    8080 # cockpit
    25565 # minecraft
    25575
    3390 # rdp
  ];
  networking.firewall.allowedUDPPorts = [ 
    25565 # minecraft
  ]; 
  networking.firewall.checkReversePath = "loose";
  networking.networkmanager.enable = true;
  networking.hostName = "t510";

  #tailscale - arc
  services.tailscale.enable = true;

# Services

  #cockpit
  services.cockpit.enable = true;

  # minecraft - service
  services.minecraft-server = {
    enable = true;
    eula = true;
    declarative = true;
    serverProperties = {
      server-port = 25565;
      motd = "t510";
      enable-rcon = true;
      rcon-port = 25575;
      rcon-password = "adminadmin";
    };
  };

#util
  # desktop manager - util
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.gnome.gnome-remote-desktop.enable = true;

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
