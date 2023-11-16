{ custom, ... }:

{
  sops.age.keyFile = "/home/${custom.username}/.config/sops/age/keys.txt";
}
