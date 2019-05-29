#!/usr/bin/env bash

# Copyright 2019 British Broadcasting Corporation
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
AUTH_BRANCH=$6

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

git clone --verbose https://github.com/bbc/nmos-common.git

cd /home/vagrant/nmos-common
git checkout $COMMON_BRANCH
pip install -e .
pip3 install -e .
install -m 666 /dev/null /var/log/nmos.log
