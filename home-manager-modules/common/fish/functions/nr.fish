function nr --description "nix run from nixpkgs"
	nix run --verbose "nixpkgs#$argv[1]"
end
