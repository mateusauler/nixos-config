# My NixOS config

To deploy it, simply run:

```bash
sudo nixos-rebuild switch --flake git+https://codeberg.org/mateusauler/nixos-config#[hostname]
```
Where `[hostname]` is the name of the host that you want to instantiate.
