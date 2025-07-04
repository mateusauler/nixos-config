#!/usr/bin/env bash

function usage {
	echo "Usage:"
	echo "  $0 OPTIONS <nixos-rebuild parameters>"
	echo
	echo "Options:"
	echo "  -h, --host             comma-separated list of hosts to deploy (can be specified multiple times)"
	echo "  -a, --addr, --address  optional comma-separated list of addresses to deploy (matched in order to each host)"
	echo "                         if a host does not have a matching address, its hostname is used instead"
	echo "  -n, --nom              pass  nixos-rebuild output through nom"
	echo "  --help                 display this message"
}

function error {
	echo -e "Error: $1\n" 1>&2
	usage
	exit 1
}

function missing_argument {
	error "Missing argument for $1 parameter"
}

source .env

EXTRA_ARGS=()
HOSTS=()
ADDRESSES=()
NOM=false
SUDO=

while (( $# > 0 )); do
	case $1 in
		-h|--host)
			(( $# <= 1 )) && missing_argument "$1"
			HOSTS+=("${2//,/ }")
			shift 2
			;;

		-a|--addr|--address)
			(( $# <= 1 )) && missing_argument "$1"
			ADDRESSES+=("${2//,/ }")
			shift 2
			;;

		-n|--nom)
			NOM=true
			shift
			;;

		--help)
			usage
			exit 0
			;;

		*)
			EXTRA_ARGS+=("$1")
			shift
			;;
	esac
done

flake_root=$(realpath "$(dirname "$0")")

function run
{
	# Run sudo to ulock it for the next run, sunce nom grabs stderr output
	[[ -n $SUDO ]] && $SUDO true

	if $NOM
	then
		$SUDO "$@" --log-format internal-json 2>&1 | nom --json
	else
		$SUDO "$@"
	fi
}

function deploy_local
{
	SUDO=sudo
	run nixos-rebuild --flake "$flake_root" "${EXTRA_ARGS[@]}"
}

function deploy_remote
{
	for host in "${HOSTS[@]}"; do
		addr="$host"

		if (( $# > 0 )); then
			addr="$1"
			shift
		fi

		# This is deprecated. But this script - for whatever reason - invokes the old nixos-rebuild that doesn't accept --ask-sudo-password...
		export NIX_SSHOPTS="-t"
		run nixos-rebuild --flake "$flake_root#$host" --target-host "$addr" --use-remote-sudo "${EXTRA_ARGS[@]}"
	done
}

if (( ${#HOSTS[@]} <= 0 )); then
	deploy_local
else
	deploy_remote "${ADDRESSES[@]}"
fi
