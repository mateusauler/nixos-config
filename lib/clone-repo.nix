{ lib, pkgs, ... }:

{ path, url, ssh-uri ? null }:
let
  git = "${pkgs.git}/bin/git";
  ssh = "${pkgs.openssh}/bin/ssh";
  grep = "${pkgs.gnugrep}/bin/grep";
  ssh-check =
    if ssh-uri == null then ""
    else if lib.hasPrefix "git@github" ssh-uri then "${ssh} -T git@github.com 2>&1 | ${grep} \"You've successfully authenticated\""
    else if lib.hasPrefix "git@gitlab" ssh-uri then "${ssh} -T git@gitlab.com"
    else throw "I don't know how to check for ssh access for this host. (ssh uri: '${ssh-uri}')";
in
''
  if [ ! -d ${path} ]; then
    $DRY_RUN_CMD ${git} clone $VERBOSE_ARG ${url} ${path}
    $DRY_RUN_CMD pushd ${path}
      ${lib.optionalString (ssh-uri != null) "$DRY_RUN_CMD ${ssh-check} && $DRY_RUN_CMD ${git} remote $VERBOSE_ARG set-url origin ${ssh-uri}"}
      $DRY_RUN_CMD ${git} pull $VERBOSE_ARG || true
    $DRY_RUN_CMD popd
  fi
''
