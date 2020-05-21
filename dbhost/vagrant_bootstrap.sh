#!/bin/bash

# -- ================
# -- dbhost bootstrap
# -- ================

# -- run as root
sudo su root

# -- common task for all Vagrant provisioned VMs
. $HOME/comun.sh

# -- install mysql software
@ -- configure root password and pass through ssh install errors
echo "mysql-server-5.7 mysql-server/root_password password root" | debconf-set-selections
echo "mysql-server-5.7 mysql-server/root_password_again password root" | debconf-set-selections

DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server-5.7
apt-get -y install mysql-server-5.7
apt-get -y install mysql-client-5.7

# -- install filebeat transport
apt-get install apt-transport-https
apt update
apt install filebeat


# -- configure mysql
# enable all logs
sed -i 's/#general_log_file/general_log_file/g' /etc/mysql/mysql.conf.d/mysqld.cnf    
sed -i 's/#general_log/general_log/g'           /etc/mysql/mysql.conf.d/mysqld.cnf    
sed -i 's/#long_query_time/long_query_time/g'   /etc/mysql/mysql.conf.d/mysqld.cnf    
sed -i 's/#log-queries-not-using-indexes/log-queries-not-using-indexes/g' /etc/mysql/mysql.conf.d/mysqld.cnf    

# -- configure filebeat to send mysql error log to eshost (10.0.0.10)
mv /etc/filebeat/filebeat.yml /etc/filebeat/filebeat.yml.ORIGINAL
echo "filebeat.inputs:"                > /etc/filebeat/filebeat.yml
echo "- type: log"                    >> /etc/filebeat/filebeat.yml 
echo "  enabled: true"                >> /etc/filebeat/filebeat.yml 
echo "  paths:"                       >> /etc/filebeat/filebeat.yml 
echo "    - /var/log/mysql/error.log" >> /etc/filebeat/filebeat.yml 
echo "output.logstash:"               >> /etc/filebeat/filebeat.yml 
echo "  hosts: [\"eshost:5044\"]"     >> /etc/filebeat/filebeat.yml 
echo "logging.level: debug         "  >> /etc/filebeat/filebeat.yml 


# -- install create mysql.service and filebeat.service
systemctl enable mysql.service
systemctl start  mysql.service
systemctl enable filebeat.service
systemctl start  filebeat.service


# -- populate classicmodels (mysql sample database)
cat $HOME/mysqlsampledatabase.sql | mysql -uroot -p$ROOTPASSWORD 

# -- create script to query database and generate errors
# -- echo "use classicmodels; select * from customers;" | mysql -uroot -pWrongPassword.
cat > /home/vagrant/generate_sql_logs.sh << EOF
#!/bin/bash
ROOTPASSWORD=root
echo "use classicmodels; select * from customers;" | mysql -uroot -pROOTPASSWORD
echo "use classicmodels; select * from customers;" | mysql -uroot -pWrongPassword
echo "SET GLOBAL event_scheduler = ON;" | mysql -uroot -pROOTPASSWORD
echo "SET GLOBAL event_scheduler = OFF;" | mysql -uroot -pROOTPASSWORD
EOF

chmod 755 /home/vagrant/generate_sql_logs.sh

# -- create cron job (every minute)
# Start job every 1 minute
echo "* * * * * vagrant /home/vagrant/generate_sql_logs.sh" >> /etc/crontab
