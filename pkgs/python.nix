pkgs:
with pkgs; (python27.buildEnv.override {
    ignoreCollisions = true; # by default from copy/paste
    extraLibs = with python27Packages; [
      # Add pythonPackages without the prefix
      websocket_client
      sexpdata
    ];
})


# todo: install vim from scratch in my own freakin derivation
