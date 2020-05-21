@echo off
cd eshost
vagrant destroy -f
cd ..
cd dbhost
vagrant destroy -f
cd ..
cd kihost
vagrant destroy -f
cd ..