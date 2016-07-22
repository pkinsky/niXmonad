let vimrc = pkgs.fetchurl {
      name = "default-vimrc";
      url = https://projects.archlinux.org/svntogit/packages.git/plain/trunk/archlinux.vim?h=packages/vim?id=68f6d131750aa778807119e03eed70286a17b1cb;
      sha256 = "18ifhv5q9prd175q3vxbqf6qyvkk6bc7d2lhqdk0q78i68kv9y0c";
    };
    pkgs = import <nixpkgs> {};
    my_python = with pkgs; (python27.buildEnv.override {
        ignoreCollisions = true; # by default from copy/paste
        extraLibs = with python27Packages; [
          # Add pythonPackages without the prefix
          websocket_client
          sexpdata
        ];
    });

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

  buildInputs = [ ncurses pkgconfig my_python ];
    
  nativeBuildInputs = [ gettext ];

  configureFlags = [
    "--enable-multibyte"
    "--enable-nls"
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
