# IP assignments
## Networks
|Name|VLAN|Subnet|Pool Size|Range|
|-|-|-|-|-|
|Default|1|10.0.0.0/24|248|10.0.0.6 - 10.0.0.254|
|Hepatica|2|10.0.2.0/24|248|10.0.2.6 - 10.0.2.254|
|Kids|3|10.0.3.0/24|248|10.0.3.6 - 10.0.3.254|
|Homelab|4|10.0.4.0/24|248|10.0.4.6 - 10.0.4.254|
|Guest|99|10.0.99.0/24|248|10.0.99.6 - 10.0.99.254|
|IoT|107|10.0.107.0/24|248|10.0.107.6 - 10.0.107.254
|Management|254|10.0.254.0/24|248|10.0.254.6 - 10.0.254.254|

## Reservations
|Device|VLAN|IP|
|-|-|-|
|USG|Management|10.0.254.1|
|US 8 PoE 150W|Management|10.0.254.2|
|US 8 60W|Management|10.0.254.3|
|US 8|Management|10.0.254.4|
|AC Pro|Management|10.0.254.5|
|U6 IW|Management|10.0.254.6|

|Proxmox|Homelab|10.0.4.10|
|Jumphost|Homelab|10.0.4.22|
|NAS|Homelab|10.0.4.200|
