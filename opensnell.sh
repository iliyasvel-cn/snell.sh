#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
CONF="/etc/opensnell/snell-server.conf"
SYSTEMD="/etc/systemd/system/opensnell.service"
apt-get install unzip -y
cd ~/
wget --no-check-certificate -O opensnell.zip https://github.com/icpz/open-snell/releases/download/v3.0.0-beta/snell-server-linux-amd64.zip
unzip -o opensnell.zip
rm -f opensnell.zip
mv snell-server opensnell-server
chmod +x opensnell-server
mv -f opensnell-server /usr/local/bin/
if [ -f ${CONF} ]; then
  echo "Found existing config..."
  else
  if [ -z ${PSK} ]; then
    PSK=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 16)
    echo "Using generated PSK: ${PSK}"
  else
    echo "Using predefined PSK: ${PSK}"
  fi
  mkdir /etc/opensnell/
  echo "Generating new config..."
  echo "[snell-server]" >>${CONF}
  echo "listen = ::0:2053" >>${CONF}
  echo "psk = ${PSK}" >>${CONF}
  echo "obfs = tls" >>${CONF}
fi
if [ -f ${SYSTEMD} ]; then
  echo "Found existing service..."
  systemctl daemon-reload
  systemctl restart snell
else
  echo "Generating new service..."
  echo "[Unit]" >>${SYSTEMD}
  echo "Description=OpenSnell Proxy Service" >>${SYSTEMD}
  echo "After=network.target" >>${SYSTEMD}
  echo "" >>${SYSTEMD}
  echo "[Service]" >>${SYSTEMD}
  echo "Type=simple" >>${SYSTEMD}
  echo "LimitNOFILE=32768" >>${SYSTEMD}
  echo "ExecStart=/usr/local/bin/opensnell-server -c /etc/opensnell/snell-server.conf" >>${SYSTEMD}
  echo "" >>${SYSTEMD}
  echo "[Install]" >>${SYSTEMD}
  echo "WantedBy=multi-user.target" >>${SYSTEMD}
  systemctl daemon-reload
  systemctl enable opensnell
  systemctl start opensnell
fi
