#Check if ALLOW ICMP FW Rule has been defined
netsh advfirewall firewall show rule status=enabled name="ICMP Allow incoming V4 echo request"