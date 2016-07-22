

let ubervim = import ./ubervim.nix ;
    run = ''${ubervim} -u $vimrc "$@"'';
    vimrc = builtins.toFile "vimrc" (builtins.readFile ./vimrc);
    sh = builtins.toFile "builder.sh" "echo ${run} > $out";
in derivation { 
  name = "ubervimrc"; 
  builder = "${pkgs.bash}/bin/bash"; 
  args = [ "${sh}" ]; 
  system = builtins.currentSystem; 
}
