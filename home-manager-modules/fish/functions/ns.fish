function ns --description "Run nix shell with the packages provided in the argument set"
	set pkgs
	for pkg in $argv[1..-1]
		set pkgs $pkgs "nixpkgs#$pkg"
	end
	set names $argv[1]
	for pkg in $argv[2..-1]
		set names "$names, $pkg"
	end
	IN_NIX_SHELL=1 NIX_SHELL_PKGS="$names" nix shell --verbose $pkgs --command $SHELL
end
