# To learn more about how to use Nix to configure your environment
# see: https://developers.google.com/idx/guides/customize-idx-env
{ pkgs, ... }: {
  # Which nixpkgs channel to use.
  channel = "stable-24.05"; # or "unstable"
  # Use https://search.nixos.org/packages to find packages
  packages = [ 
    pkgs.python3
    pkgs.python311Packages.pip
    pkgs.python311Packages.cffi
    pkgs.python311Packages.setuptools
    pkgs.python311Packages.wheel
    pkgs.python311Packages.mysqlclient
    pkgs.python311Packages.mysql-connector
    pkgs.mysql-client

    # pkgs.python3Packages.opencv4
    pkgs.opencv2
    # pkgs.python311Packages.ultralytics
    # pkgs.python311Packages.paddleocr
    # pkgs.python311Packages.paddlepaddle
    pkgs.libGL
    pkgs.libglvnd
    pkgs.libusb1
    pkgs.mesa
    pkgs.libglibutil
    pkgs.pacman
    pkgs.glib.out

    #mysql
    pkgs.mysql80
    pkgs.pkg-config
    pkgs.libmysqlclient

    #compilation
    pkgs.gcc
    pkgs.gnumake
    pkgs.stdenv.cc.cc.lib
    pkgs.binutils
    pkgs.glibc
    pkgs.glibc.dev
    #libraries
    pkgs.zlib
    pkgs.libxml2
    pkgs.openssl
    pkgs.libxcrypt
  ];
  
  # See: https://nixos.wiki/wiki/Mysql
  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
  };

  
  idx = {
    # Search for the extensions you want on https://open-vsx.org/ and use "publisher.id"
    extensions = [ "ms-python.python" ];
    workspace = {
      # Runs when a workspace is first created with this `dev.nix` file
      onCreate = {
        install = ''
          python -m venv .venv 
          source .venv/bin/activate 
          
          pip install --upgrade pip setuptools wheel

           # Set compilation flags
          export CFLAGS="-I${pkgs.libmysqlclient}/include -I${pkgs.stdenv.cc.cc.lib}/include"
          export LDFLAGS="-L${pkgs.libmysqlclient}/lib -L${pkgs.stdenv.cc.cc.lib}/lib -L${pkgs.glibc}/lib"
          export LD_LIBRARY_PATH="${pkgs.libmysqlclient}/lib:${pkgs.stdenv.cc.cc.lib}/lib:${pkgs.glibc}/lib:$LD_LIBRARY_PATH"

          # Install build dependencies
          #pip install cffi

          # Verbose mysqlclient installation
          CFLAGS="$CFLAGS" \
          LDFLAGS="$LDFLAGS" \
          #pip install mysqlclient --no-binary mysqlclient --verbose

          pip install -r requirements.txt
        '';
        
        # Open editors for the following files by default, if they exist:
        # default.openFiles = [ "README.md" "src/index.html" "main.py" ];
      }; 
      # To run something each time the workspace is (re)started, use the `onStart` hook
      onStart = {
        activateVenv = ''
          #source .venv/bin/activate

          # Reapply library paths
          #export LDFLAGS="-L${pkgs.libmysqlclient}/lib -L${pkgs.stdenv.cc.cc.lib}/lib -L${pkgs.glibc}/lib"
          #export CPPFLAGS="-I${pkgs.libmysqlclient}/include -I${pkgs.stdenv.cc.cc.lib}/include"
          #export LD_LIBRARY_PATH="${pkgs.libmysqlclient}/lib:${pkgs.stdenv.cc.cc.lib}/lib:${pkgs.glibc}/lib:$LD_LIBRARY_PATH"
        '';
      };
    };
    # Enable previews and customize configuration
    previews = {
      enable = true;
      previews = {
        web = {
          command = [ "./devserver.sh" ];
          env = { PORT = "$PORT"; };
          manager = "web";
        };
      };
    };
  };
}
