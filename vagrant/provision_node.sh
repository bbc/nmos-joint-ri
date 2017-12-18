#!/usr/bin/env bash

# Copyright 2017 British Broadcasting Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

export DEBIAN_FRONTEND=noninteractive

# All service are run as an ipstudio user
useradd ipstudio

apt-get update
apt-get install python-pip python-mock devscripts debhelper equivs -y
pip install --upgrade pip
pip install setuptools

apt-get install libavahi-compat-libdnssd1 -y

cd /home/vagrant

git clone https://github.com/bbc/nmos-common.git
git clone https://github.com/bbc/nmos-reverse-proxy.git
git clone https://github.com/bbc/nmos-node.git
git clone https://github.com/bbc/nmos-mdns-bridge.git
git clone https://github.com/bbc/nmos-device-connection-management-ri.git

pip install -I https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/pybonjour/pybonjour-1.1.1.tar.gz
pip install --no-deps gevent=="1.0.2"
pip install --no-deps greenlet=="0.4.2"
pip install --no-deps gevent-websocket=="0.9.3"
pip install --no-deps six=="1.10.0"
pip install --no-deps flask=="0.10.1"
pip install jinja2=="2.7.2"
pip install --no-deps werkzeug=="0.9.4"
pip install --no-deps itsdangerous=="0.24"
pip install --no-deps socketio-client=="0.5.3"
pip install --no-deps flask-sockets=="0.1"
pip install --no-deps pyzmq=="14.0.1"
pip install --no-deps pygments=="1.6"
pip install --no-deps python-dateutil
pip install --no-deps flask-oauthlib=="0.9.1"
pip install --no-deps ws4py=="0.3.2"
pip install --no-deps requests=="2.2.1"
pip install jsonschema=="2.3.0"
pip install netifaces

cd /home/vagrant/nmos-common
python setup.py install

cd /home/vagrant/nmos-reverse-proxy
mk-build-deps debian/control
dpkg -i *.deb
sudo apt-get -f -y install
make deb
dpkg -i ../ips-reverseproxy-common_*_all.deb
sudo apt-get -f -y install

cd /home/vagrant/nmos-mdns-bridge
mk-build-deps --install debian/control
dpkg -i *.deb
sudo apt-get -f -y install
make deb
dpkg -i ../python-mdnsbridge_0.3.0_all.deb
sudo apt-get -f -y install

cd /home/vagrant/nmos-node
mk-build-deps --install debian/control
dpkg -i *.deb
sudo apt-get -f -y install
git checkout dev
make deb
dpkg -i ../python-nodefacade_0.2.0_all.deb
sudo apt-get -f -y install

cd /home/vagrant/nmos-device-connection-management-ri
git checkout dev
python setup.py install

cp -r bin/connectionmanagement /usr/bin
cp -r share/ipp-connectionmanagement /usr/share
cp -r etc/apache2/sites-available/*.conf /etc/apache2/sites-available/
cp -r etc/init/nmosconnection.conf /etc/init
cp -r lib/systemd/system/nmosconnection.service /lib/systemd/system
cp -r var/www/connectionManagementDriver /var/www
cp -r var/www/connectionManagementUI /var/www
chmod +x /usr/bin/connectionmanagement

ln -s /lib/init/upstart-job /etc/init.d/nmosconnection
ln -s /lib/systemd/system/nmosconnection.service /etc/systemd/system/multi-user.target.wants/nmosconnection.service

service nmosconnection start
service apache2 restart
a2ensite nmos-ui.conf
service apache2 reload
