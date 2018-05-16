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

sudo apt-get install libavahi-compat-libdnssd1 -y
pip install -I https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/pybonjour/pybonjour-1.1.1.tar.gz

cd /home/vagrant

git clone --verbose https://github.com/bbc/nmos-common.git
git clone --verbose https://github.com/bbc/nmos-reverse-proxy.git
git clone --verbose https://github.com/bbc/nmos-query.git
git clone --verbose https://github.com/bbc/nmos-registration.git
git clone --verbose https://github.com/bbc/nmos-mdns-bridge.git

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
mk-build-deps debian/control
dpkg -i *.deb
sudo apt-get -f -y install
make deb
dpkg -i ../python-mdnsbridge_*_all.deb
sudo apt-get -f -y install

cd /home/vagrant/nmos-registration
mk-build-deps debian/control
dpkg -i *.deb
sudo apt-get -f -y install
make deb
dpkg -i ../python-registryaggregator_*.*_all.deb
sudo apt-get -f -y install

cd /home/vagrant/nmos-query
mk-build-deps debian/control
dpkg -i *.deb
sudo apt-get -f -y install
make deb
dpkg -i ../python-registryquery_*.*_all.deb
sudo apt-get -f -y install
