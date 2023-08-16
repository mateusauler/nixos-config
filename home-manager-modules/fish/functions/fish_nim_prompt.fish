function fish_nim_prompt
	# Colors to be used
	set -l color_bg  blue
	set -l color_ok  magenta
	set -l color_err red
	set -l color_git green
	set -l color_py  "#FFD745" # One of the Python logo colors

	# Sets the return-code-based color
	set -l retc $color_err
	test $status = 0; and set retc $color_ok

	if ! set -q __fish_git_prompt_showupstream
		set -g __fish_git_prompt_showupstream auto
	end

	# Are we in a tty ?
	function _is_tty
		tty | grep '/dev/tty' &> /dev/null
	end

	# Brackets
	set -l obracket ❬
	set -l cbracket ❭

	if _is_tty
		set obracket '<'
		set cbracket '>'
	end

	# Wraps a given text in [...]
	function _prompt_wrapper -Sa value color label
		if test -z "$value"
			return
		end

		set_color -o $color_bg
		echo -n "$obracket "
		set_color normal
		test -z $color; or set_color $color
		if ! _is_tty; and test -n "$label"
			echo -n "$label "
		end
		echo -n $value
		set_color -o $color_bg
		echo -n " $cbracket"
		set_color normal
		echo -n ' '
	end

	# Beginning of the first line
	if ! _is_tty
		set_color $retc
		echo -n '╭╼ '
	end

	# Building 'user@host cwd'
	set -l info

	# Only append 'user@host' if in an ssh session
	if test ! -z "$SSH_CLIENT"
		set -l color yellow
		if functions -q fish_is_root_user; and fish_is_root_user
			set color red
		end

		set info "$info"(set_color -o $color)
		set info "$info"$USER
		set info "$info"(set_color -o white)
		set info "$info"@
		set info "$info"(set_color -o blue)
		set info "$info"(prompt_hostname)
		set info "$info "
	end

	# Append the cwd
	set info "$info"(set_color -o white)
	set info "$info"(prompt_pwd)
	set info "$info"(set_color -o $color_bg)

	# Wrap the info
	_prompt_wrapper $info

	# Virtual Environment
	if ! set -q VIRTUAL_ENV_DISABLE_PROMPT
		set -g VIRTUAL_ENV_DISABLE_PROMPT true
	end

	_prompt_wrapper (basename "$VIRTUAL_ENV") $color_py 

	# git
	set -l prompt_git (fish_git_prompt '%s')
	_prompt_wrapper "$prompt_git" $color_git 

	# Battery status
	type -q acpi
	and test (acpi -a 2> /dev/null | string match -r off)
	and _prompt_wrapper (acpi -b | cut -d' ' -f 4-) $retc B

	# Vi-mode
	# Won't display the mode prompt if it's in its default state (insert)
	if test "$fish_key_bindings" = fish_vi_key_bindings; or test "$fish_key_bindings" = fish_hybrid_key_bindings
		set -l mode
		set -l color

		switch $fish_bind_mode
			case default
				set color red
				set mode N
			case replace_one
				set color green
				set mode R1
			case replace
				set color cyan
				set mode R
			case visual
				set color magenta
				set mode V
		end

		_prompt_wrapper $mode $color
	end

	# New line
	echo

	# Background jobs
	set_color normal

	for job in (jobs)
		if ! _is_tty
			set_color $retc
			echo -n '│ '
		end
		set_color $color_bg
		echo $job
	end

	# Last line of of the prompt
	set -l last_line ╰╼
	_is_tty; and set last_line '$'

	set_color normal
	set_color $retc
	echo -n "$last_line "
	set_color normal
end
