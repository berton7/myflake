{
  stdenv,
  fetchgit,
  python312Packages,
  libnotify,
}: let
  suntime = with python312Packages;
    buildPythonPackage rec {
      pname = "suntime";
      version = "1.3.2";
      format = "setuptools";
      src = fetchPypi {
        inherit pname version format;
        sha256 = "SDT3kHrRPbs2mQTLX0N27cCwbG6KHPwKrBJo9k0Ozc8=";
      };
      doCheck = false;
      nativeBuildInputs = [
        setuptools
        setuptools-scm
        wheel
      ];
    };

  bin = ''
    #!/bin/bash
    cd $out/opt/yin-yang
    python3 -Om yin_yang "\$@"
  '';
in
  stdenv.mkDerivation rec {
    pname = "yin_yang";
    version = "3.4";

    src = fetchgit {
      url = "https://github.com/oskarsh/Yin-Yang";
      rev = "v${version}";
      sha256 = "eBtchc3QHn5AdTFjmY9of/VcCAiJYIjwCVNUDSU8ySM=";
    };

    propagatedNativeBuildInputs = [
      python312Packages.python
      (python312Packages.python.withPackages (pp:
        with pp; [
          systemd
          pyside6
          psutil
          requests
          python-dateutil
        ]))
      suntime
      libnotify
    ];

    propagatedBuildInputs = [
      python312Packages.python
      (python312Packages.python.withPackages (pp:
        with pp; [
          systemd
          pyside6
          psutil
          requests
          python-dateutil
        ]))
      suntime
      libnotify
    ];

    patches = [
      ./daemon_handler.patch
    ];

    buildPhase = ''
      echo "${bin}" > yin-yang
      chmod +x yin-yang
    '';

    installPhase = ''
      mkdir -p $out/bin
      cp yin-yang $out/bin/yin-yang

      mkdir -p $out/opt/yin-yang
      # cp -r ./yin_yang $out/opt/yin-yang/
      cp -r ./{resources,yin_yang} $out/opt/yin-yang/

      mkdir -p $out/share/applications
      cp ./resources/Yin-Yang.desktop $out/share/applications

      mkdir -p $out/share/icons/hicolor/scalable/apps
      cp ./resources/logo.svg $out/share/icons/hicolor/scalable/apps
    '';
  }
