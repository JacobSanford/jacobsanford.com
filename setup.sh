#!/usr/bin/env bash
sudo gem install bundler
bundle install
rake
rake install['octofound']
rake generate
git submodule init
git submodule update

echo" git@github.com:JacobSanford/jacobsanford.com.git"
