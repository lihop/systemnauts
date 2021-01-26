{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  nativeBuildInputs = with pkgs;
    [
      alsaLib
      cacert
      dotnetCorePackages.sdk_5_0
      dotnetPackages.Nuget
      freetype
      gcc
      git
      libGL
      libGLU
      libpulseaudio
      libudev.dev
      mono
      openssl
      pkg-config
      scons
      xorg.libX11
      xorg.libXcursor
      xorg.libXext
      xorg.libXfixes
      xorg.libXi
      xorg.libXinerama
      xorg.libXrandr
      xorg.libXrender
    ];

  MONO_PREFIX = "${pkgs.mono}";
}
