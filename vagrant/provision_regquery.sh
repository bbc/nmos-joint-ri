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
apt-get install python-pip devscripts equivs -y
pip install --upgrade pip
pip install setuptools

sudo apt-get install libavahi-compat-libdnssd1 -y
pip install -I https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/pybonjour/pybonjour-1.1.1.tar.gz

cd /home/vagrant

git clone --verbose https://github.com/bbc/nmos-common.git
git clone --verbose https://github.com/bbc/nmos-reverse-proxy.git
git clone --verbose https://github.com/bbc/nmos-query.git
git clone --verbose https://github.com/bbc/nmos-registration.git
git clone --verbose https://github.com/bbc/nmos-mdns-bridge.git

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
