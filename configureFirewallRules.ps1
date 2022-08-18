netsh advFirewall firewall set rule group='Distributed Transaction Coordinator' new enable=no

netsh advFirewall firewall add rule name="Rosen Service Platform Web Site (in)" dir=in localport=[PLATFORMWEBSITEPORT] protocol=TCP action=allow enable=yes
netsh advFirewall firewall add rule name="Rosen Service Platform Web Site (out)" dir=out localport=9000 protocol=TCP action=allow enable=yes
netsh advFirewall firewall add rule name="Rosen Service Platform (in)" dir=in localport=4040 protocol=TCP action=allow enable=yes
netsh advFirewall firewall add rule name="Rosen Service Platform (out)" dir=out localport=4040 protocol=TCP action=allow enable=yes