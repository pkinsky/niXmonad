pkgs: name: 
let vimrc = builtins.toFile "vimrc" (builtins.readFile ./vimrc);
in pkgs.vim_configurable.customize {
      name = name;
      # the call vam bit here is a total shim until I add ensime-vim to the list
      vimrcConfig.customRC = ''
        so ${vimrc}
        call vam#ActivateAddons(['ensime-vim'])
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
    }

