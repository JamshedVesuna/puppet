#!/bin/bash
sudo apt-get install git puppet
git clone https://github.com/JamshedVesuna/puppet.git /tmp/puppet
sudo puppet apply /tmp/puppet/jamshed.pp
