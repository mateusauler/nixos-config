#!/usr/bin/env bash

function usage {
	echo "Usage:"
	echo "  $0 OPTIONS [nixos-rebuild parameters] OPERATION"
	echo
	echo "Options:"
	echo "  -h, --host             comma-separated list of hosts to deploy (can be specified multiple times)"
	echo "  -a, --addr, --address  optional comma-separated list of addresses to deploy (matched in order to each host)"
	echo "                         if a host does not have a matching address, its hostname is used instead"
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

EXTRA_ARGS=()
HOSTS=()
ADDRESSES=()

while [[ $# -gt 0 ]]; do
	case $1 in
		-h|--host)
			(( $# <= 1 )) && missing_argument $1
			HOSTS+=("${2//,/ }")
			shift 2
			;;

		-a|--addr|--address)
			(( $# <= 1 )) && missing_argument $1
			ADDRESSES+=("${2//,/ }")
			shift 2
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

(( ${#HOSTS[@]} <= 0 )) && error "No hosts were provided"

echo "${EXTRA_ARGS[@]}" | grep -qvwE "boot|switch|test" && error "Missing nixos-rebuild operation (boot, switch or test)"

function match_host_ip {
	for host in ${HOSTS[@]}; do
		addr="$host"

		if (( $# > 0 )); then
			addr="$1"
			shift
		fi

		nixos-rebuild --flake $(realpath $(dirname "$0"))\#"$host" --target-host "$addr" --use-remote-sudo ${EXTRA_ARGS[@]}
	done
}

match_host_ip ${ADDRESSES[@]}
