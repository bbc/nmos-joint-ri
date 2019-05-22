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

COMMON_BRANCH=$1
MDNS_BRIDGE_BRANCH=$2
REVERSE_PROXY_BRANCH=$3
NODE_BRANCH=$4
CONNECTION_BRANCH=$7

export DEBIAN_FRONTEND=noninteractive
APT_TOOL='apt-get -o Debug::pkgProblemResolver=yes --no-install-recommends -y'

# All service are run as an ipstudio user
useradd ipstudio
mkdir /home/ipstudio
chown -R ipstudio /home/ipstudio

sed -i 's/# deb-src/deb-src/' /etc/apt/sources.list
apt-get update
apt-get install python-pip python3-pip python-mock python3-mock devscripts debhelper equivs python3-setuptools python-stdeb python3 libffi-dev tox -y
pip install setuptools

cd /home/vagrant

git clone https://github.com/bbc/nmos-common.git
git clone https://github.com/bbc/nmos-reverse-proxy.git
git clone https://github.com/bbc/nmos-node.git
git clone https://github.com/bbc/nmos-mdns-bridge.git
git clone https://github.com/bbc/nmos-device-connection-management-ri.git

cd /home/vagrant/nmos-common
git checkout $COMMON_BRANCH
pip install -e .
pip3 install -e .
install -m 666 /dev/null /var/log/nmos.log

cd /home/vagrant/nmos-reverse-proxy
git checkout $REVERSE_PROXY_BRANCH
make dsc
mk-build-deps --install deb_dist/nmosreverseproxy_*.dsc --tool "$APT_TOOL"
make deb
dpkg -i dist/ips-reverseproxy-common_*_all.deb
sudo apt-get -f -y install

cd /home/vagrant/nmos-mdns-bridge
git checkout $MDNS_BRIDGE_BRANCH
make dsc
mk-build-deps --install deb_dist/mdnsbridge_*.dsc --tool "$APT_TOOL"
make deb
dpkg -i dist/python-mdnsbridge_*_all.deb
sudo apt-get -f -y install

cd /home/vagrant/nmos-node
git checkout $NODE_BRANCH
make dsc
mk-build-deps --install deb_dist/nodefacade_*.dsc --tool "$APT_TOOL"
make deb
dpkg -i dist/python-nodefacade_*_all.deb
sudo apt-get -f -y install

cd /home/vagrant/nmos-device-connection-management-ri
git checkout $CONNECTION_BRANCH
mk-build-deps --install deb_dist/connectionmanagement_*.dsc --tool "$APT_TOOL"
make deb
dpkg -i dist/python-connectionmanagement_*_all.deb
sudo apt-get -f -y install

cp -r bin/connectionmanagement /usr/bin
cp -r share/ipp-connectionmanagement /usr/share
cp -r var/www/connectionManagementDriver /var/www
cp -r var/www/connectionManagementUI /var/www
chmod +x /usr/bin/connectionmanagement

service apache2 restart
a2ensite nmos-ui.conf
service apache2 reload
