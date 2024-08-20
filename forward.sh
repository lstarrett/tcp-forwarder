#!/bin/bash

# TCP Forwarder
#
# This script will configure the local host to forward all TCP traffic (bound for all ports or a
# specific port) to a destination host, masquerading as the original client so that responses are sent
# directly back to the initiating client.
#
# Utilizes the iptables utility, and tested on Linux hosts, but should work anywhere iptables is
# found.
#
# Author(s): Lucas Starrett (luacs.c.starrett@gmail.com) License: MIT


display_help() {
  echo "Usage:"
  echo "   -h | --help       Display this help text"
  echo "   -v | --version    Display TCP Forwarder version"
  echo "   -d | --dest-ip    Destination host IP to forward TCP traffic"
  echo "   -p | --dest-port  Local and destination host port to listen for traffic and forward to destination host on the same port"
  echo "   -l | --list       List all configured iptables NAT rules"
  echo "   -f | --flush      Flush iptables NAT rules configured by this tool (NOTE: currently, this will flush all NAT rules)"
  echo "   --brew-config     Display config, log, and err file paths if installed and run as a homebrew service (NOTE: not yet implemented"
}


display_version() {
  echo "TCP Forwarder v1.0"
}

list_rules() {
  echo "Currently configured NAT rules:"
  echo
  sudo iptables -t nat -L --line-numbers
  echo
}

# Forward TCP traffic to destination host, masquerading as original source
forward_tcp() {

  # Flush all NAT rules and exit
  if [ $flush -eq 1 ]; then
    echo "Flushing NAT rules..."
    sudo iptables -t nat -F PREROUTING
    sudo iptables -t nat -F POSTROUTING
    if [ $list -eq 1 ]; then
      list_rules
    fi
    exit 0

  # Configure and set NAT rules for IP forwarding
  else
    echo "Configuring TCP Forwarding..."
    echo "Destination IP: $dest_ip"
    prerouting="sudo iptables -t nat -A PREROUTING -p tcp -j DNAT --to-destination $dest_ip"
    postrouting="sudo iptables -t nat -A POSTROUTING -p tcp -j MASQUERADE -d $dest_ip"

    if [[ -z $dest_port ]]; then
      echo "Destination port: ALL"
    else
      echo "Destination port: $dest_port"
      prerouting+=" --dport $dest_port"
      postrouting+=" --dport $dest_port"
    fi

    # Execute the constructed iptables commands to configure NAT rules
    eval $prerouting
    eval $postrouting
  fi

  # List rules if -l|--list option is set
  if [ $list -eq 1 ]; then
    list_rules
  fi
}


# check arguments
if [ $# -eq 0 ]; then
  display_help
else

  list=0
  flush=0
  # Check flags and parse options
  while [ $# -gt 0 ]; do
    case "$1" in
      -h|--help)
        display_help
        exit 0
        ;;
      -v|--version)
        display_version
        exit 0
        ;;
      -d|--dest-ip)
        shift
        if [ $# -gt 0 ]; then
          dest_ip=$1
        else
          display_help
          exit 1
        fi
        shift
        ;;
      -p|--dest-port)
        shift
        if [ $# -gt 0 ]; then
          dest_port=$1
        else
          display_help
          exit 1
        fi
        shift
        ;;
      -f|--flush)
        flush=1
        shift
        ;;
      -l|--list)
        list=1
        shift
        ;;
      --brew-config)
        display_homebrew_config
        exit 0
        ;;
      *)
        echo >&2 "Invalid argument. Aborting."
        display_help
        exit 1
        ;;
    esac
  done

  # check that user has provided required --dest-ip argument
  if [[ -z $dest_ip && $flush -eq 0 ]]; then
    if [ $list -eq 1 ]; then
      list_rules
      exit 0
    fi
    echo >&2 "Missing required --dest-ip argument. Aborting."
    display_help
    exit 1
  fi

  # Run TCP forwarder
  forward_tcp

fi
