# TCP Forwarder
Utility script to configure a proxy host to forward all TCP traffic from a client host (bound for
all ports or a specific port) to a destination host, masquerading as the original client so that
responses from the destination host are sent directly back to the initiating client.

Utilizes the iptables program, and is tested on Linux hosts, but should work anywhere iptables is
found.

## Requirements
* bash
* iptables
* netcat (for testing)
* root permissions (depending on host configuration)


## Usage
Run as a stand-alone script:
1. Clone or download this repository
2. `./forward.sh --help` for usage info

## Testing
Once rules are in place on a proxy host, start a simple TCP server on the destination host using
netcat, and then use netcat on a client host to send traffic to the proxy host, and observe the
received (and acknowledged) traffic on the destination host.

1. On proxy host: `./forward.sh -d <dest_ip> -p <dest_port>`
2. On the destination host: `nc -l <dest port>`
3. On the client host: `nc <proxy_ip> <dest_port>`
4. On the client host: Type messages to destination host, forwarded through proxy host (followed by the return key)
5. On the destination host: Observe received messages!
6. On the destination host: Close listening TCP server with `ctrl + D`
7. On the client host: Observe the TCP client connection closed, demonstrating TCP responses received
   by client (confirming successful source masquerading by proxy host)

