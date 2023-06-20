#!/bin/bash

# Instalar OpenVPN
sudo apt install openvpn

# Configurar el archivo client.conf
sudo tee /etc/openvpn/client.conf > /dev/null <<EOF
client
dev tun
proto udp
remote esparzasolar.duckdns.org 1194
resolv-retry infinite
nobind
user nobody
group nogroup
persist-key
persist-tun
ca ca.crt
cert client.crt
key client.key
remote-cert-tls server
tls-auth ta.key 1
cipher AES-256-CBC
verb 3
EOF

# Obtener los archivos de configuración del servidor
CLIENTE_NUMERO="1"
sudo scp eneko@esparzasolar.duckdns.org:/etc/openvpn/client${CLIENTE_NUMERO}/ca.crt /etc/openvpn/
sudo scp eneko@esparzasolar.duckdns.org:/etc/openvpn/client${CLIENTE_NUMERO}/client.crt /etc/openvpn/
sudo scp eneko@esparzasolar.duckdns.org:/etc/openvpn/client${CLIENTE_NUMERO}/client.key /etc/openvpn/
sudo scp eneko@esparzasolar.duckdns.org:/etc/openvpn/client${CLIENTE_NUMERO}/ta.key /etc/openvpn/

# Iniciar el servicio OpenVPN
sudo systemctl start openvpn@client

# Verificar el estado de la conexión VPN
sudo systemctl status openvpn@client

# Mostrar la dirección IP asignada por la VPN
ip addr

# Para probar Conectar usando el archivo de configuración
# sudo openvpn --config /etc/openvpn/client.conf
