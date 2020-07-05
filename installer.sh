#!/usr/bin/env bash 

## Update machine
DEBIAN_FRONTEND=noninteractive apt -qqy update
DEBIAN_FRONTEND=noninteractive apt-get -qqy -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' upgrade

## Install Code Server
curl -fOL "https://github.com/cdr/code-server/releases/download/v${release}/code-server_${release}_amd64.deb"
sudo dpkg -i "code-server_${release}_amd64.deb"
systemctl --user enable code-server
systemctl --user start code-server


## Install Caddy
echo "deb [trusted=yes] https://apt.fury.io/caddy/ /" | tee -a /etc/apt/sources.list.d/caddy-fury.list
DEBIAN_FRONTEND=noninteractive apt -qqy update
DEBIAN_FRONTEND=noninteractive apt -qqy -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' install caddy

## Backup original caddyfile
mv /etc/caddy/Caddyfile /root/Caddyfile-original

## Generate new Caddyfile 
cat >/etc/caddy/Caddyfile <<EOL
${fqdn}
reverse_proxy 127.0.0.1:8080
EOL

## Set permissions and ownership on new Caddyfile
chmod 0644 /etc/caddy/Caddyfile
chown root:root /etc/caddy/Caddyfile

## Restart Caddy so Let's Encrypt can do it's thing
systemctl reload caddy