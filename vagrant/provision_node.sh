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
mkdir /home/ipstudio
chown -R ipstudio /home/ipstudio

apt-get update
apt-get install python-pip python-mock devscripts debhelper equivs python3-setuptools python-stdeb -y
pip install setuptools

apt-get install libavahi-compat-libdnssd1 -y

cd /home/vagrant

git clone https://github.com/bbc/nmos-common.git
git clone https://github.com/bbc/nmos-reverse-proxy.git
git clone https://github.com/bbc/nmos-node.git
git clone https://github.com/bbc/nmos-mdns-bridge.git
git clone https://github.com/bbc/nmos-device-connection-management-ri.git

cd /home/vagrant/nmos-common
pip install -e . --process-dependency-links
install -m 666 /dev/null /var/log/nmos.log

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
dpkg -i ../python-mdnsbridge_*_all.deb
sudo apt-get -f -y install

cd /home/vagrant/nmos-node
mk-build-deps --install debian/control
dpkg -i *.deb
sudo apt-get -f -y install
make deb
dpkg -i ../python-nodefacade_*_all.deb
sudo apt-get -f -y install

cd /home/vagrant/nmos-device-connection-management-ri
dpkg -i *.deb
sudo apt-get -f -y install
make deb
dpkg -i ../python-connectionmanagement_*_all.deb
sudo apt-get -f -y install

cp -r bin/connectionmanagement /usr/bin
cp -r share/ipp-connectionmanagement /usr/share
cp -r var/www/connectionManagementDriver /var/www
cp -r var/www/connectionManagementUI /var/www
chmod +x /usr/bin/connectionmanagement

service apache2 restart
a2ensite nmos-ui.conf
service apache2 reload
