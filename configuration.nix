{ config, pkgs, ... }:

let zsh = "/run/current-system/sw/bin/zsh";
    home = "/home/pkinsky";

    theme = {
      package = pkgs.theme-vertex;
      name = "Vertex-Dark";
    };
    user = { # don't forget to set a password with passwd
      name = "pkinsky";
      group = "users";
      extraGroups = ["networkmanager" "wheel"];
      uid = 1000;
      createHome = true;
      home = home;
      shell = zsh;
    };
    xmonad_hs = pkgs.fetchgit {
      url = "https://github.com/pkinsky/xmonad";
      rev = "f730199532fd470f7c6d599fa4f7766e50a3f6a4";
      sha256 = "foobar";
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
      '';
      vimrcConfig.vam.knownPlugins = pkgs.vimPlugins;
      vimrcConfig.vam.pluginDictionaries = [ 
        #load always
        { names = [
            "Syntastic"
            "ctrlp" 
            "colors-solarized" 
            "supertab" 
            "nerdtree" 
            "rainbow_parentheses"
          ]; 
        } 
        #only load for scala files
        #{ name = "vim-scala"; ft_regex = "^.php\$";} <- not found
        #{ name = "vim-scala"; filename_regex = "^.php\$";}
      ];
    };
in {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # from vbox tutorial
  virtualisation.virtualbox.guest.enable = true;
  virtualisation.docker.enable = true;

  boot = {
    loader.grub = { # bootloader setup/voodoo
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
      extraPackages = hp: [
        hp.taffybar
      ];
    };
 

    displayManager = {
      sessionCommands = ''
        echo "thug life: linking $out to ${home}/.xmonad"
        mkdir ${home}/foobar
        echo "test pass"
        ln -s $out ${home}/.xmonad
      '';
      lightdm = {
        enable = true; # todo: change to my own img
        background = "${pkgs.fetchurl {
          url = "https://jb55.com/img/haskell-space.jpg";
          md5 = "04d86f9b50e42d46d566bded9a91ee2c";
        }}";
        greeters.gtk = {
          theme = theme;
          # iconTheme = icon-theme;
        };
      };
    };
  };  


  # initial user setup
  users.extraUsers.pkinsky = user;
  
  users.extraGroups.vboxusers.members = [ "pkinsky" ];
  users.extraGroups.docker.members = [ "pkinsky" ];

  users.defaultUserShell = zsh;
  users.mutableUsers = true;


  networking.hostName = "nixos"; # Define your hostname.

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    wget
    #vim superseded by my_vim (configured)
    binutils
    git
    chromium
    unzip
    zip
    xclip
    tree
    my_vim
    rxvt_unicode
    #fonts
    corefonts
    inconsolata
    ubuntu_font_family
    fira-code
    fira-mono
    source-code-pro
    ipafont
    #end fonts block

    scala
    sbt

    docker
    torbrowser
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
      antigen theme bira

      # Tell antigen that you're done.
      antigen apply     
    '';
  };

  systemd.user.services.urxvtd = {
    enable = true;
    description = "RXVT-Unicode Daemon";
    wantedBy = [ "default.target" ];
    path = [ pkgs.rxvt_unicode-with-plugins ];
    serviceConfig = {
      Restart = "always";
      ExecStart = "${pkgs.rxvt_unicode-with-plugins}/bin/urxvtd -q -o";
    };
  };

}
