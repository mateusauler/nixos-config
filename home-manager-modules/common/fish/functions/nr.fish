function nr --description "nix run from nixpkgs"
	nix run --verbose "nixpkgs#$argv[1]" $argv[2..-1]
end
