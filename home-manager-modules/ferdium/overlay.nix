# TODO: Only do this if using wayland
final: prev: {
  ferdium = prev.ferdium.overrideAttrs (old: {
      postFixup = ''
        ${old.postFixup}
        sed -i -E "s/Exec=ferdium/Exec=ferdium --enable-features=UseOzonePlatform --ozone-platform=wayland/" $out/share/applications/ferdium.desktop
      '';
    }
  );
}

