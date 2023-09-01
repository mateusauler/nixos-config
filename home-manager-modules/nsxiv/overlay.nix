final: prev: {
  nsxiv = prev.nsxiv.overrideAttrs (old: {
      postInstall = "sed -iE \"s/Exec\\s*=\\s*nsxiv\\s*\\(.*\\)$/Exec=nsxiv -a \\1/\" $out/share/applications/nsxiv.desktop";
    }
  );
}
