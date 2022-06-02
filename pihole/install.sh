#!/usr/bin/env bash
cloudflare_url="https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb"
pihole_url="https://install.pi-hole.net"
pihole_pass="${1}"

apt update && apt -y upgrade && apt -y install curl git 

# Download Cloudflared
curl -LsO "${cloudflare_url}"

# Install Cloudflared
apt install -y ./cloudflared-linux-amd64.deb

# Configure Cloudflared proxy
tee /etc/systemd/system/cloudflared-proxy-dns.service >/dev/null <<EOF
[Unit]
Description=DNS over HTTPS (DoH) proxy client
Wants=network-online.target nss-lookup.target
Before=nss-lookup.target

[Service]
AmbientCapabilities=CAP_NET_BIND_SERVICE
CapabilityBoundingSet=CAP_NET_BIND_SERVICE
DynamicUser=yes
ExecStart=/usr/local/bin/cloudflared proxy-dns --port 5053

[Install]
WantedBy=multi-user.target
EOF

# Enable Cloudflared service
systemctl enable --now cloudflared-proxy-dns

# Create password for pihole
pihole_pass=$(echo -n "${pihole_pass}" | sha256sum -z | sed 's/\s.*$//'| sha256sum | sed 's/\s.*$//')

# Create pihole config directory
mkdir -p /etc/pihole

# Create setupVars.conf for pihole
tee /etc/pihole/setupVars.conf >/dev/null <<EOF
PIHOLE_INTERFACE=eth0
IPV4_ADDRESS=10.0.0.53/24
IPV6_ADDRESS=
PIHOLE_DNS_1=127.0.0.1#5053
PIHOLE_DNS_2=1.1.1.1
QUERY_LOGGING=true
INSTALL_WEB_SERVER=true
INSTALL_WEB_INTERFACE=true
LIGHTTPD_ENABLED=true
CACHE_SIZE=10000
DNS_FQDN_REQUIRED=true
DNS_BOGUS_PRIV=true
DNSMASQ_LISTENING=local
WEBPASSWORD=${pihole_pass}
BLOCKING_ENABLED=true
EOF

# Install pihole
curl -L "${pihole_url}" | PIHOLE_SKIP_OS_CHECK=true bash /dev/stdin --unattended

# Copy local DNS records
mv /tmp/custom.list /etc/pihole/custom.list

# Change system DNS-server
rm -f /etc/resolv.conf
echo nameserver 127.0.0.1 | tee /etc/resolv.conf >/dev/null