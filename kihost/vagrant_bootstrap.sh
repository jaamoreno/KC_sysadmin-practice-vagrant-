#!/bin/bash

# -- ================
# -- kihost bootstrap
# -- ================

# -- run as root
sudo su root

# -- common task for all Vagrant provisioned VMs
. $HOME/comun.sh

# -- JAVA install (Kibana prerequisite)
apt-get install -y openjdk-8-jdk 

# -- set JAVA_HOME to avoid some warnings in logs
export JAVA_HOME=`find /usr/lib/jvm/ -type l | head -1`
echo "JAVA_HOME fijado a [$JAVA_HOME]" 

# install Kibana
sudo apt-get install kibana

# -- Kibana config
mv /etc/kibana/kibana.yml /etc/kibana/kibana.yml.ORIGINAL

echo "server.port: \"5601\"                       "  > /etc/kibana/kibana.yml
# -- host IP to allow external access
echo "server.host: \"10.0.0.12\"                  " >> /etc/kibana/kibana.yml
echo "server.name: \"kihost\"                     " >> /etc/kibana/kibana.yml
echo "elasticsearch.hosts: \"http://eshost:9200\" " >> /etc/kibana/kibana.yml
echo "elasticsearch.username: \"elastic\"         " >> /etc/kibana/kibana.yml
echo "elasticsearch.password: \"changeme\"        " >> /etc/kibana/kibana.yml





# -- create (and start) Kibana services
systemctl enable kibana.service
systemctl start kibana.service  
