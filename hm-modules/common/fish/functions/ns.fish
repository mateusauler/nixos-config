function ns --description "Run nix shell with the packages provided in the argument set"
	set pkgs
	for pkg in $argv[1..-1]
		if string match -qv '*#*' "$pkg"
			set pkgs $pkgs "nixpkgs#$pkg"
		else
			set pkgs $pkgs "$pkg"
		end
	end
	set names $argv[1]
	for pkg in $argv[2..-1]
		set names "$names, $pkg"
	end
	IN_NIX_SHELL=1 NIX_SHELL_PKGS="$(test -n "$NIX_SHELL_PKGS" && echo "$NIX_SHELL_PKGS :: ")$names" nom shell --impure --verbose $pkgs --command $SHELL
end
