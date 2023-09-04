# My NixOS config

### This is a work in progress, as I'm still migrating my configs to this repo.

You probably shouldn't use this as is. It's only public for my convenience and in the hopes it will be useful for someone.

To deploy it, simply run:

```bash
sudo nixos-rebuild switch --flake 'github:mateusauler/nixos-config'#[hostname]
```
Where `[hostname]` is the name of the host that you want to instantiate.
