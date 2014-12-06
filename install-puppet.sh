#!/bin/bash
apt-get install git, puppet
curl -L https://github.com/JamshedVesuna/puppet.git > /tmp/puppet
puppet apply jamshed.pp
