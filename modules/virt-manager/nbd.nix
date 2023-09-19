{ config, lib, pkgs, ... }:

let
  mount-nbd = pkgs.writeShellScriptBin "mount-nbd" ''
    function usage {
      pname=$(basename $0)
      echo "Usage:"
      echo "  $pname [OPTIONS] DISK"
      echo
      echo "Options:"
      echo "  -n, --nbd-number    number of the nbd device to connect to"
      echo "  -p, --partition     which partition to mount (defaults to all)"
      echo "  --rw                mount disk read-write"
      echo "  -h, --help          display this message"
    }

    POSITIONAL_ARGS=()

    RO="--read-only"

    while [[ $# -gt 0 ]]; do
      case $1 in
        -n|--nbd-number)
          NBD="$2"
          shift
          shift
          ;;
        --rw)
          RO=""
          shift
          ;;
        -p|--partition)
          PART="$2"
          shift
          shift
          ;;
        -h|--help)
          usage
          exit 0
          ;;
        -*|--*)
          echo "Error: Unknown option $1"
          echo
          usage
          exit 1
          ;;
        *)
          POSITIONAL_ARGS+=("$1")
          shift
          ;;
      esac
    done

    set -- "''${POSITIONAL_ARGS[@]}" # restore positional parameters

    [[ ''${#POSITIONAL_ARGS[@]} -le 0 ]] && echo "Error: Missing disk argument" && echo && usage && exit 1

    if [ -z $NBD ]; then
      # Get the numbers of the nbd devices that have partitions associated with them
      # This is a hacky way to get the devices that have a connection
      parts=($(find /dev -name "nbd*p*" | sed -E "s|/dev/nbd([0-9]+)p.*|\\1|" | uniq | sort -n))

      NBD=0

      # If there is at least one, find the last one's number and add 1 to it
      if [[ ''${#parts[@]} -gt 0 ]]; then
        last=''${parts[-1]}
        NBD=$((last + 1))
      fi
    fi
    DEV="/dev/nbd''${NBD}"

    echo "Connecting to device $DEV..."
    sudo qemu-nbd --connect $DEV $RO $1

    function mount_disk {
      sudo ${pkgs.udisks}/bin/udisksctl mount -b $1
    }

    if [ ! -z $PART ]; then
      mount_disk "''${DEV}p$PART"
    else
      # Mount all partitions of the device
      parts=$(find /dev -name "nbd''${NBD}p*")

      for part in $parts; do
        mount_disk $part
      done
    fi
  '';

  cfg = config.modules.virt-manager.nbd;
in
{
  options.modules.virt-manager.nbd.enable = pkgs.lib.mkTrueEnableOption "nbd";
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ mount-nbd ];
    boot.kernelModules = [ "nbd" ];
  };
}
