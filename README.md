# Ansible Collection - tesseract.network

Documentation for the collection.

- Tailscale subnet router not functioning
- DNS not responding via tailscale unless ran as root
- self-host ACME-DNS server: https://github.com/joohoi/acme-dns#self-hosted

nmcli con mod "Wired connection 1" ipv4.addresses 192.168.1.8/24
nmcli con mod "Wired connection 1" ipv4.gateway 192.168.1.1
nmcli con mod "Wired connection 1" ipv4.dns "8.8.8.8","8.8.4.4"
nmcli con mod "Wired connection 1" ipv4.method manual
nmcli con down "Wired connection 1" && nmcli con up "Wired connection 1"

mkdir -p /etc/systemd/resolved.conf.d
nano /etc/systemd/resolved.conf.d/10-make-dns-work.conf
[Resolve]
DNSStubListener=no
systemctl restart systemd-resolved

adduser admin
usermod -aG sudo admin


apt install sudo python3


  tls {
    resolvers 1.1.1.1
  }