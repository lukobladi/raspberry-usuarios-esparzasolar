#!/bin/bash

# Modo Punto de acceso wifi

# COpiar script Hotspot a directorio bin
cp autohotspotN /usr/bin/

# Instalar hostapd
apt update && apt upgrade -y
apt install hostapd dnsmasq -y

# Desactivar inicio automático para cuando haya conectividad wifi con el router
systemctl unmask hostapd
systemctl disable hostapd
systemctl disable dnsmasq

# Cambiar país de wifi
raspi-config nonint do_wifi_country ES

# Configurar Hostapd
cat <<EOF > /etc/hostapd/hostapd.conf
# 2.4GHz setup wifi 802.11 b,g,n
interface=wlan0
driver=nl80211
ssid=RPiHotspotN
hw_mode=g
channel=8
wmm_enabled=0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=1234567890
wpa_key_mgmt=WPA-PSK
wpa_pairwise=CCMP TKIP
rsn_pairwise=CCMP

# 802.11n - Cambia ES por el código de país de tu WiFi
country_code=ES
ieee80211n=1
ieee80211d=1
EOF

# Configurar archivo de configuración de Hostapd
sed -i 's/#DAEMON_CONF=""/DAEMON_CONF="\/etc\/hostapd\/hostapd.conf"/' /etc/default/hostapd

# Configurar para que funcione como router y servidor DHCP
cat <<EOF >> /etc/dnsmasq.conf
# AutoHotspot config
interface=wlan0
bind-dynamic
server=8.8.8.8
domain-needed
bogus-priv
dhcp-range=192.168.50.150,192.168.50.200,12h
EOF

# Activar IP forwarding
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
sysctl -p

# Configurar DHCP
echo "nohook wpa_supplicant" >> /etc/dhcpcd.conf

# Crear un servicio para que arranque el hotspot al inicio
cat <<EOF > /etc/systemd/system/autohotspot.service
[Unit]
Description=Automatically generates an internet Hotspot when a valid ssid is not in range
After=multi-user.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/bin/autohotspotN

[Install]
WantedBy=multi-user.target
EOF

systemctl enable autohotspot.service
