#!/bin/bash
#Creamos el usuario y grupo de sistema 'odoo12':
sudo adduser --system --quiet --shell=/bin/bash --home=/opt/odoo12 --gecos 'odoo12' --group odoo12
sudo adduser --system --quiet --shell=/bin/bash --home=/opt/odoo12-dev --gecos 'odoo12-dev' --group odoo12-dev
sudo adduser --system --quiet --shell=/bin/bash --home=/opt/odoo12-pre --gecos 'odoo12-pre' --group odoo12-pre
#Creamos en directorio en donde se almacenará el archivo de configuración y log de odoo:
sudo mkdir /etc/odoo12 && sudo mkdir /var/log/odoo12/
sudo mkdir /etc/odoo12-dev && sudo mkdir /var/log/odoo12-dev/
sudo mkdir /etc/odoo12-pre && sudo mkdir /var/log/odoo12-pre/
# Instalamos Postgres y librerías base del sistema:
sudo apt-get update && sudo apt-get install postgresql postgresql-server-dev-10 build-essential python3-pil python3-lxml python-ldap3 python3-dev python3-pip python3-setuptools npm nodejs git gdebi libldap2-dev libsasl2-dev  libxml2-dev libxslt1-dev libjpeg-dev -y
#Descargamos odoo version 12 desde git:
sudo git clone --depth 1 --branch 12.0 https://github.com/odoo/odoo /opt/odoo12/odoo
cp -a /opt/odoo12/server /opt/odoo12-dev/odoo12-dev
cp -a /opt/odoo12/server /opt/odoo12-pre/odoo12-pre
#sudo git clone --depth 1 --branch 12.0 https://github.com/odoo/odoo /opt/odoo12-dev/odoo
#sudo git clone --depth 1 --branch 12.0 https://github.com/odoo/odoo /opt/odoo12-pre/odoo
#Damos permiso al directorio que contiene los archivos de OdooERP  e instalamos las dependencias de python3:
sudo chown odoo12:odoo12 /opt/odoo12/ -R && sudo chown odoo12:odoo12 /var/log/odoo12/ -R && cd /opt/odoo12/odoo && sudo pip3 install -r requirements.txt
sudo chown odoo12-dev:odoo12-dev /opt/odoo12-dev/ -R && sudo chown odoo12-dev:odoo12-dev /var/log/odoo12-dev/ -R && cd /opt/odoo12-dev/odoo && sudo pip3 install -r reqrequirements.txt
sudo chown odoo12-pre:odoo12-pre /opt/odoo12-pre/ -R && sudo chown odoo12-pre:odoo12-pre /var/log/odoo12-pre/ -R && cd /opt/odoo12-pre/odoo && sudo pip3 install -r requirements.txt
#Usamos npm, que es el gestor de paquetes Node.js para instalar less:
sudo npm install -g less less-plugin-clean-css -y && sudo ln -s /usr/bin/nodejs /usr/bin/node
#Descargamos dependencias e instalar wkhtmltopdf para generar PDF en odoo
sudo apt install xfonts-base xfonts-75dpi -y
cd /tmp
wget http://security.ubuntu.com/ubuntu/pool/main/libp/libpng/libpng12-0_1.2.54-1ubuntu1.1_amd64.deb && sudo dpkg -i libpng12-0_1.2.54-1ubuntu1.1_amd64.deb
wget https://downloads.wkhtmltopdf.org/0.12/0.12.5/wkhtmltox_0.12.5-1.bionic_amd64.deb && sudo dpkg -i wkhtmltox_0.12.5-1.bionic_amd64.deb
sudo ln -s /usr/local/bin/wkhtmltopdf /usr/bin/
sudo ln -s /usr/local/bin/wkhtmltoimage /usr/bin/
#wget -N http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz && sudo gunzip GeoLiteCity.dat.gz && sudo mkdir /usr/share/GeoIP/ && sudo mv GeoLiteCity.dat /usr/share/GeoIP/
#Creamos un usuario 'odoo12' para la base de datos y instancias de postgres:
sudo su - postgres -c "createuser -s odoo12"
sudo su - postgres -c "createuser -s odoo12-dev"
sudo su - postgres -c "createuser -s odoo12-pre"
pg_createcluster -p 5433 10 dev
pg_createcluster -p 5434 10 pre

#Creamos la configuracion de Odoo:
sudo su - odoo12 -c "/opt/odoo12/odoo/odoo-bin --addons-path=/opt/odoo12/odoo/addons -s --stop-after-init"
sudo su - odoo12-dev -c "/opt/odoo12-dev/odoo/odoo-bin --addons-path=/opt/odoo12-dev/odoo/addons -s --stop-after-init"
sudo su - odoo12-pre -c "/opt/odoo/odoo12-pre/odoo-bin --addons-path=/opt/odoo12-pre/odoo/addons -s --stop-after-init"
#Creamos el archivo de configuracion de odoo:
sudo mv /opt/odoo12/.odoorc /etc/odoo12/odoo12.conf
sudo mv /opt/odoo12-dev/.odoorc /etc/odoo12-dev/odoo12-dev.conf
sudo mv /opt/odoo12-pre/.odoorc /etc/odoo12-pre/odoo12-pre.conf
#Agregamos los siguientes parámetros al archivo de configuración de odoo:
sudo sed -i "s,^\(logfile = \).*,\1"/var/log/odoo12/odoo12-server.log"," /etc/odoo12/odoo12.conf
#sudo sed -i "s,^\(logrotate = \).*,\1"True"," /etc/odoo12/odoo12.conf
#sudo sed -i "s,^\(proxy_mode = \).*,\1"True"," /etc/odoo12/odoo12.conf
sudo sed -i "s,^\(logfile = \).*,\1"/var/log/odoo12-dev/odoo12-dev-server.log"," /etc/odoo12-dev/odoo12-dev.conf
#sudo sed -i "s,^\(logrotate = \).*,\1"True"," /etc/odoo12-dev/odoo12-dev.conf
#sudo sed -i "s,^\(proxy_mode = \).*,\1"True"," /etc/odoo12-dev/odoo12-dev.conf
sudo sed -i "s,^\(logfile = \).*,\1"/var/log/odoo12-pre/odoo12pre-server.log"," /etc/odoo12-pre/odoo12-pre.conf
#sudo sed -i "s,^\(logrotate = \).*,\1"True"," /etc/odoo12-pre/odoo12.conf
#sudo sed -i "s,^\(proxy_mode = \).*,\1"True"," /etc/odoo12-pre/odoo12.conf

#Creamos el archivo de inicio del servicio de Odoo:
sudo cp /opt/odoo12/odoo/debian/init /etc/init.d/odoo12 && sudo chmod +x /etc/init.d/odoo12
sudo ln -s /opt/odoo12/odoo/odoo-bin /usr/bin/odoo12
sudo update-rc.d -f odoo12 start 20 2 3 4 5 .
sudo service odoo12 start
sudo cp /opt/odoo12-dev/odoo/debian/init /etc/init.d/odoo12-dev && sudo chmod +x /etc/init.d/odoo12-dev
sudo ln -s /opt/odoo12-dev/odoo/odoo-bin /usr/bin/odoo12-dev
sudo update-rc.d -f odoo12-dev start 20 2 3 4 5 .
sudo service odoo12-dev start
sudo cp /opt/odoo12-pre/odoo/debian/init /etc/init.d/odoo12-pre && sudo chmod +x /etc/init.d/odoo12-pre
sudo ln -s /opt/odoo12-pre/odoo/odoo-bin /usr/bin/odoo12-pre
sudo update-rc.d -f odoo12-pre start 20 2 3 4 5 .
sudo service odoo12-pre start

