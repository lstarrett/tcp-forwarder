# TCP Forwarder
Utility script to configure the local host to forward all TCP traffic (bound for all ports or a
specific port) to a remote host, masquerading as the original client so that responses are sent
directly back to the initiating client.

Utilizes the iptables program, and is tested on Linux hosts, but should work anywhere iptables is
found.

Author(s): Lucas Starrett (luacs.c.starrett@gmail.com) License: MIT
