{ ... }:

[
  # Temporary fix for https://github.com/hyprwm/Hyprland/issues/6681
  (final: prev: {
    hyprland = prev.hyprland.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [ ./hyprland-6881.diff ];
    });
  })
]
