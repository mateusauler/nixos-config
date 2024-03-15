# My NixOS config

To deploy it, simply run:

```bash
sudo nixos-rebuild switch --flake 'github:mateusauler/nixos-config'#[hostname]
```
Where `[hostname]` is the name of the host that you want to instantiate.
