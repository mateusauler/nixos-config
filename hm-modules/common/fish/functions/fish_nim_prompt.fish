function fish_nim_prompt
	# Colors to be used
	set -l color_bg  blue
	set -l color_ok  magenta
	set -l color_err red
	set -l color_git green
	set -l color_py  "#FFD745" # One of the Python logo colors

	# Sets the return-code-based color
	set -l retc $color_err
	if test $status = 0
		set retc $color_ok
	end

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

	# Wraps a given text in <...>
	function _prompt_wrapper -Sa value color label
		if test -z "$value"
			return
		end

		set_color -o $color_bg
		echo -n "$obracket "

		set_color normal
		test -z $color || set_color $color

		if ! _is_tty && test -n "$label"
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

	function is_root
		functions -q fish_is_root_user && fish_is_root_user
	end

	# Only show 'user@host' if in an ssh session
	if is_root || test ! -z "$SSH_CLIENT"
		set -l color yellow
		if is_root
			set color red
		end

		set -l user_host
		set user_host "$user_host"(set_color -o $color)
		set user_host "$user_host"$USER
		set user_host "$user_host"(set_color -o white)
		set user_host "$user_host"@
		set user_host "$user_host"(set_color -o blue)
		set user_host "$user_host"(prompt_hostname)

		_prompt_wrapper $user_host
	end

	# Display cwd
	_prompt_wrapper (prompt_pwd) white

	if test -n "$DISTROBOX_ENTER_PATH"
		_prompt_wrapper "$(hostname -s)" yellow 
	end

	if test -n "$IN_NIX_SHELL"
		set -l shell_name

		if test -n "$name"
			set shell_name "$(echo $name | sed 's/-env//; s/-/ /g')"
		end

		if test -n "$NIX_SHELL_PKGS"
			set shell_name "$(test -n "$shell_name" && echo "$shell_name :: ")$NIX_SHELL_PKGS"
		end

		if test -z "$shell_name"
			set shell_name nix-shell
		end

		_prompt_wrapper "$shell_name" blue 
	end

	# Virtual Environment
	if ! set -q VIRTUAL_ENV_DISABLE_PROMPT
		set -g VIRTUAL_ENV_DISABLE_PROMPT true
	end

	_prompt_wrapper (basename "$VIRTUAL_ENV") $color_py 

	# git
	set -l prompt_git (fish_git_prompt '%s')
	_prompt_wrapper "$prompt_git" $color_git 

	# Battery status
	if type -q acpi && test (acpi -a 2> /dev/null | string match -r off)
		_prompt_wrapper (acpi -b | cut -d' ' -f 4-) $retc B
	end

	# Execution time of the last command
	if set -q CMD_DURATION && test $CMD_DURATION -gt 0
		set -l seconds      (math -s 0 $CMD_DURATION / 1000)
		set -l milliseconds (math -s 0 $CMD_DURATION % 1000)
		set -l minutes      (math -s 0 $seconds      / 60)
		set -l seconds      (math -s 0 $seconds      % 60)
		set -l hours        (math -s 0 $minutes      / 60)
		set -l minutes      (math -s 0 $minutes      % 60)

		set -l formatted_timespan

		function append_time -Sa num id
			if test $num -gt 0
				set formatted_timespan "$formatted_timespan $num$id"
			end
		end

		append_time $hours "h"
		append_time $minutes "m"
		append_time $seconds "s"
		append_time $milliseconds "ms"

		# Remove the first character of the $formatted_timespan string, as it's always a space
		set formatted_timespan (string sub -s 2 $formatted_timespan)

		_prompt_wrapper $formatted_timespan yellow
	end

	# Vi-mode
	# Won't display the mode prompt if it's in its default state (insert)
	if test "$fish_key_bindings" = fish_vi_key_bindings || test "$fish_key_bindings" = fish_hybrid_key_bindings
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
	if _is_tty
		set last_line '$'
	end

	set_color normal
	set_color $retc
	echo -n "$last_line "
	set_color normal
end
