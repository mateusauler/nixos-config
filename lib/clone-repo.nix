{ lib, pkgs, ... }:

{ path, url, ssh-uri ? null }:
let
  git = "${pkgs.git}/bin/git";
in
''
  if [ ! -d ${path} ]; then
    $DRY_RUN_CMD ${git} clone $VERBOSE_ARG ${url} ${path}
    $DRY_RUN_CMD pushd ${path}
      ${lib.optionalString (ssh-uri != null) "$DRY_RUN_CMD ${git} remote $VERBOSE_ARG set-url origin ${ssh-uri}"}
      $DRY_RUN_CMD ${git} pull $VERBOSE_ARG || true
    $DRY_RUN_CMD popd
  fi
''
