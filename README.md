# My NixOS config

**This is a work in progress, as I'm still migrating my configs to this repo.**

You probably shouldn't use this as is. It's only public for my convenience and in the hopes it will be useful for someone.

This config will deploy only on a system with a hostname that matches one of the directories in ```hosts/```.
To deploy it, clone the repo and run this command:

```bash
sudo nixos-rebuild switch --flake /path/to/the/repo
```

Or simply run:

```bash
sudo nixos-rebuild switch --flake 'github:mateusauler/nixos-config'
```
