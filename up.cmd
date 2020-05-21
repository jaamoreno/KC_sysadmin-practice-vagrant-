@echo off

REM --- 1º la BBDD 
cd dbhost
vagrant up
cd ..

REM -- 2º KIBANA 
cd kihost
vagrant up
cd ..

REM -- 3º (ultimo lugar) ELASTICSEARCH
cd eshost
vagrant up
cd ..
