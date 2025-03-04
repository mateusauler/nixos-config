function nr --description "nix run from nixpkgs"
	set runpkg "$argv[1]"
	if string match -qv '*#*' "$runpkg"
		set runpkg "nixpkgs#$runpkg"
	end
	nix run --impure --verbose "$runpkg" $argv[2..-1]
end
