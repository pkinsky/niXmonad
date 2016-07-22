pkgs:

let my_python = with pkgs; (python27.buildEnv.override {
        ignoreCollisions = true; # by default from copy/paste
        extraLibs = with python27Packages; [
          # Add pythonPackages without the prefix
          websocket_client
          sexpdata
        ];
    });
    vimrc = builtins.toFile "vimrc" (builtins.readFile ./vimrc);
in with pkgs; stdenv.mkDerivation rec {
  name = "vim-${version}";
  version = "7.4.827";

  src = fetchFromGitHub {
    owner = "vim";
    repo = "vim";
    rev = "v${version}";
    sha256 = "1m34s2hsc5lcish6gmvn2iwaz0k7jc3kg9q4nf30fj9inl7gaybs";
  };

  enableParallelBuilding = true;

  buildInputs = [ ncurses pkgconfig my_python gtk2 ];
    
  nativeBuildInputs = [ gettext ];

  configureFlags = [
    "--with-features=huge"
    "--enable-multibyte"
    "--enable-nls"
    "--enable-gui=gtk2"
    "--enable-pythoninterp"
    "--with-python-config-dir=${python}/lib/python2.7"
  ];

  # confirmed: this does get run
  postInstall = ''
    ln -s $out/bin/vim $out/bin/vi
    mkdir -p $out/share/vim
    cp "${vimrc}" $out/share/vim/vimrc
  '';


  __impureHostDeps = [ "/dev/ptmx" ];

  # To fix the trouble in vim73, that it cannot cross-build with this patch
  # to bypass a configure script check that cannot be done cross-building.
  # http://groups.google.com/group/vim_dev/browse_thread/thread/66c02efd1523554b?pli=1
  # patchPhase = ''
  #   sed -i -e 's/as_fn_error.*int32.*/:/' src/auto/configure
  # '';

  meta = with stdenv.lib; {
    description = "The most popular clone of the VI editor";
    homepage    = http://www.vim.org;
    license = licenses.vim;
    maintainers = with maintainers; [ lovek323 ];
    platforms   = platforms.unix;
  };
}



# todo: separation between vimrc and vim build (2x derivations)
# goal: no recompilation of vim every time I change vimrc
