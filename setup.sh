#!/bin/bash
sudo apt-get update
sudo apt-get -y install puppet
sudo puppet apply jamshed.pp
