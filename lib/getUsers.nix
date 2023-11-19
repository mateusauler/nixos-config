{ lib, ... }:

lib.foldl'
  (acc: u: acc // {
    ${u} = import ../users/${u};
  })
  { }
  (lib.readDirNames ../users)

