@echo off
cd eshost
vagrant halt
echo --- eshost parada
cd ..
cd dbhost
vagrant halt
echo --- dbhost parada
cd ..
cd kihost
vagrant halt
echo --- kihost parada
cd ..