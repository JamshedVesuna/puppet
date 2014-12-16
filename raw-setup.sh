#!/bin/bash
sudo apt-get -y install git puppet
git clone https://github.com/JamshedVesuna/puppet.git /tmp/puppet
sudo puppet apply /tmp/puppet/jamshed.pp
