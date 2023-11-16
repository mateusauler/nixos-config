function nr --description "nix run from nixpkgs"
	nix run "nixpkgs#$argv[1]"
end
