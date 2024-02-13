function fish_powerline_prompt --description 'Powerline-style prompt'
	set -l color_cwd $fish_color_cwd
	set -l suffix
	switch "$USER"
		case root toor
			if set -q fish_color_cwd_root
				set -l color_cwd $fish_color_cwd_root
			end
			set suffix '#'
		case '*'
			set suffix '$'
	end

	set -g color_bg_usr black
	set -g color_fg_pwd '#000'
	set -g color_bg_pwd '#6393ed'
	set -g color_bg_git '#76bf01'
	set -g color_fg_git $color_fg_pwd
	set -g color_bg_vip '#4d4'
	set -g color_fg_vip '#000'

	set -l curr_mode

	switch $fish_bind_mode
		case default
			set curr_mode 'N'
		case insert
			set curr_mode 'I'
		case replace_one
			set curr_mode 'R1'
		case replace
			set curr_mode 'R'
		case visual
			set curr_mode 'V'
	end

	if tty | grep '/dev/tty' &> /dev/null
		echo -n $curr_mode $USER
		set_color $color_cwd
		echo -n -s ' ' (prompt_pwd)
		set_color normal
		echo -n -s ' ' $suffix ' '
	else
		if test $curr_mode != 'I'
			set_color $color_bg_vip
			set_color -r
			echo -n -s ''
			set_color normal
			set_color -b $color_bg_vip
			set_color $color_fg_vip
			echo -n -s " $curr_mode "
			set_color -b $color_bg_pwd
			set_color $color_bg_vip
		else
			set_color $color_bg_pwd
			set_color -r
		end

		echo -n ''
		set_color normal

		set_color -b $color_bg_pwd
		set_color $color_fg_pwd
		echo -n -s ' ' (prompt_pwd) ' '
		set_color normal

		function git_prompt
			set_color $color_bg_pwd
			set_color -b $color_bg_git
			echo -n -s ' '
			set_color $color_fg_git
			echo -n -s ' ' $argv[1] ' '
			set_color normal
			set_color $color_bg_git
			echo -n -s ''
			set_color normal
		end

		if test -d .git and git rev-parse --git-dir &> /dev/null
			git_prompt (git branch --show-current)
		else if test -d "$HOME/.cfg" && pwd | grep -E "^$HOME" &> /dev/null
			git_prompt (c branch --show-current)
		else
			set_color $color_bg_pwd
			echo -n ''
			set_color normal
		end

		echo -n -s ' '
	end

	set -e color_bg_usr
	set -e color_fg_pwd
	set -e color_bg_pwd
	set -e color_bg_git
	set -e color_fg_git
	set -e color_bg_vip
	set -e color_fg_vip
end