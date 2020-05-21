#!/bin/bash

# -- ================
# -- eshost bootstrap
# -- ================

# -- run as root
sudo su root

# -- common task for all Vagrant provisioned VMs
. $HOME/comun.sh

# -- JAVA install
apt-get install -y openjdk-8-jdk 

# -- set JAVA_HOME to avoid some warnings in logs
export JAVA_HOME=`find /usr/lib/jvm/ -type l | head -1`
echo "JAVA_HOME fijado a [$JAVA_HOME]" 

# -- elasticsearch install
apt-get install elasticsearch 

# -- logstash install
apt-cache policy logstash
apt-get install logstash


# -- Elasticsearch config
sed -i 's/#cluster.name: my-application/cluster.name: miApp/g' /etc/elasticsearch/elasticsearch.yml 
sed -i 's/#node.name: node-1/node.name: dbhost/g' /etc/elasticsearch/elasticsearch.yml 
sed -i 's/#network.host: 192.168.0.1/network.host: eshost/g' /etc/elasticsearch/elasticsearch.yml 
sed -i 's/#http.port: 9200/http.port: 9200/g' /etc/elasticsearch/elasticsearch.yml 

# -- Logstash config
echo "path.data: /var/lib/logstash      "  > /etc/logstash/logstash.yml
echo "path.config: /etc/logstash/conf.d " >> /etc/logstash/logstash.yml
echo "http.host: "eshost"               " >> /etc/logstash/logstash.yml
echo "http.port: 9600                   " >> /etc/logstash/logstash.yml  
echo "path.logs: /var/log/logstash      " >> /etc/logstash/logstash.yml


cat > /etc/logstash/conf.d/mysqlerrorlog.conf << EOF
input {
    beats {
       port => "5044"
    }
}

filter {
grok {
match => { "message" => ["%{LOCALDATETIME:[mysql][error][timestamp]} ([%{DATA:[mysql][error][level]}] )?%{GREEDYDATA:[mysql][error][message]}", "%{TIMESTAMP_ISO8601:[mysql][error][timestamp]} %{NUMBER:[mysql][error][thread_id]} [%{DATA:[mysql][error][level]}] %{GREEDYDATA:[mysql][error][message1]}", "%{GREEDYDATA:[mysql][error][message2]}"] }
pattern_definitions => {
"LOCALDATETIME" => "[0-9]+ %{TIME}"
}
remove_field => "message"
}
mutate {
rename => { "[mysql][error][message1]" => "[mysql][error][message]" }
}
mutate {
rename => { "[mysql][error][message2]" => "[mysql][error][message]" }
}
date {
match => [ "[mysql][error][timestamp]", "ISO8601", "YYMMdd H:m:s" ]
remove_field => "[apache2][access][time]"
}
mutate {
remove_field => [ "host" ]
}
}

output {
elasticsearch {
action => "index"
hosts => "http://eshost:9200"
index => "customlogs-mysql"
}
}
EOF


# -- create (and start) logstash and elasticsearch services
systemctl enable logstash.service
systemctl enable elasticsearch.service
systemctl start logstash.service  
systemctl start elasticsearch.service


