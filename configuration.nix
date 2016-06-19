{ config, pkgs, ... }:

#caches = [ "https://cache.nixos.org/"];
#nixfiles = "${home}/etc/nix-files";
#machineConfig = import "${nixfiles}/machines/${machine}.nix" pkgs;
#machine = "monad";
#nixpkgsConfig = import "${home}/.nixpkgs/config.nix";
#userConfig = (nixpkgsConfig {inherit pkgs;}).userConfig;

let zsh = "/run/current-system/sw/bin/zsh";
    home = "/home/pkinsky";
    user = {
      name = "pkinsky";
      group = "users";
      extraGroups = ["networkmanager" "wheel"];
      uid = 1000;
      createHome = true;
      home = home;
      shell = zsh;
    };
    antigen = pkgs.fetchgit {
      url = "https://github.com/zsh-users/antigen";
      rev = "1359b9966689e5afb666c2c31f5ca177006ce710";
      sha256 = "0fqxidxrjli1a02f5564y6av5jz32sh86x5yq6rpv1hhr54n521w";
    };
    vim = "vim-conf";
    my_vim = pkgs.vim_configurable.customize {
      name = vim;
      vimrcConfig.customRC = ''
        filetype plugin indent on
        set nocompatible
        syntax enable
        set background=dark
        colorscheme solarized
        set nostartofline

        " fixes backspace, see http://stackoverflow.com/questions/5419848/backspace-doesnt-work-in-gvim-7-2-64-bit-for-windows
        set backspace=2
        set backspace=indent,eol,start

        nnoremap <F4> :NERDTreeToggle<CR>  
        " and some more stuff...
      '';
      vimrcConfig.vam.knownPlugins = pkgs.vimPlugins;
      vimrcConfig.vam.pluginDictionaries = [ 
        #load always
        { names = [ "Syntastic" "ctrlp" "colors-solarized" "supertab" "nerdtree" "rainbow_parentheses"]; } 
        #only load for scala files
        #{ name = "vim-scala"; ft_regex = "^.php\$";} <- not found
        #{ name = "vim-scala"; filename_regex = "^.php\$";}
      ];
    };
    #storeFile = fileSrc : builtins.toFile (baseNameOf fileSrc) (builtins.readFile fileSrc);
    #test = storeFile "/etc/nixos/dotfiles/test.dot"
in {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # from vbox tutorial
  virtualisation.virtualbox.guest.enable = true;

  boot = {
    loader.grub = { # bootloader voodoo
      enable = true;
      version = 2;
      # Define on which hard drive you want to install Grub.
      device = "/dev/sda";
    };


    # Also remove the fsck that runs at startup. It will always fail to run, stopping your boot until you press *.
    initrd.checkJournalingFS = false;
  };

  # initial wm stuff
  services.xserver = {
    enable = true;
    layout = "us";
    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
    };
    
  };  

  # initial user stuff
  users.extraUsers.pkinsky = user;

  
  
  users.extraGroups.vboxusers.members = [ "pkinsky" ]; #???
  users.extraGroups.docker.members = [ "pkinsky" ]; #???

  users.defaultUserShell = zsh;
  users.mutableUsers = true;


  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Select internationalisation properties.
  # i18n = {
  #   consoleFont = "Lat2-Terminus16";
  #   consoleKeyMap = "us";
  #   defaultLocale = "en_US.UTF-8";
  # };

  # Set your time zone.
  # time.timeZone = "Europe/Amsterdam";



  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    wget
    #vim
    binutils
    git
    chromium
    unzip
    zip
    xclip
    tree
    my_vim
  ];

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "16.03";
  
  programs.zsh = {
    enable = true;
    shellAliases = {
      v = "${vim} -g";
      g = "git";
    };
    enableCompletion = true;
    interactiveShellInit = ''
      source ${antigen}/antigen.zsh

      # Load the oh-my-zsh's library.
      antigen use oh-my-zsh

      # Bundles from the default repo (robbyrussell's oh-my-zsh).
      antigen bundle git
      antigen bundle git-extras
      antigen bundle cabal
      antigen bundle sbt
      antigen bundle scala

      # Syntax highlighting bundle.
      antigen bundle zsh-users/zsh-syntax-highlighting

      # Load the theme.
      antigen theme sunrise

      # Tell antigen that you're done.
      antigen apply     
    '';
  };

}
