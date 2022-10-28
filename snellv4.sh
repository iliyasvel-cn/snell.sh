#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
CONF="/etc/snellv4/snellv4-server.conf"
SYSTEMD="/etc/systemd/system/snellv4.service"
apt-get install unzip -y
cd ~/
wget --no-check-certificate -O snell.zip https://github.com/surge-networks/snell/releases/download/v3.0.1/snell-server-v3.0.1-linux-amd64.zip
unzip -o snellv4.zip
rm -f snellv4.zip
chmod +x snellv4-server
mv -f snellv4-server /usr/local/bin/
if [ -f ${CONF} ]; then
  echo "Found existing config..."
  else
  if [ -z ${PSK} ]; then
    PSK=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 16)
    echo "Using generated PSK: ${PSK}"
  else
    echo "Using predefined PSK: ${PSK}"
  fi
  mkdir /etc/snellv4/
  echo "Generating new config..."
  echo "[snell-server]" >>${CONF}
  echo "listen = ::0:60000" >>${CONF}
  echo "psk = ${PSK}" >>${CONF}
  echo "obfs = tls" >>${CONF}
fi
if [ -f ${SYSTEMD} ]; then
  echo "Found existing service..."
  systemctl daemon-reload
  systemctl restart snellv4
else
  echo "Generating new service..."
  echo "[Unit]" >>${SYSTEMD}
  echo "Description=Snell Proxy Service" >>${SYSTEMD}
  echo "After=network.target" >>${SYSTEMD}
  echo "" >>${SYSTEMD}
  echo "[Service]" >>${SYSTEMD}
  echo "Type=simple" >>${SYSTEMD}
  echo "LimitNOFILE=32768" >>${SYSTEMD}
  echo "ExecStart=/usr/local/bin/snellv4-server -c /etc/snellv4/snellv4-server.conf" >>${SYSTEMD}
  echo "" >>${SYSTEMD}
  echo "[Install]" >>${SYSTEMD}
  echo "WantedBy=multi-user.target" >>${SYSTEMD}
  systemctl daemon-reload
  systemctl enable snellv4
  systemctl start snellv4
fi
