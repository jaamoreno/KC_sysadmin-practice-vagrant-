#!/bin/bash

# -- common tasks for every Vagrant VM 
# -- this script run under root account

# ==================
#  unique /etc/hosts
# ==================
echo "                   " >> /etc/hosts
echo "10.0.0.10    eshost" >> /etc/hosts
echo "10.0.0.11    dbhost" >> /etc/hosts
echo "10.0.0.12    kihost" >> /etc/hosts

# -- logstash, elasticsearch
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-6.x.list
apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv D88E42B4

# -- performance co pilot
curl 'https://bintray.com/user/downloadSubjectPublicKey?username=pcp' | apt-key add -
$ echo "deb https://dl.bintray.com/pcp/trusty xenial main" | sudo tee -a /etc/apt/sources.list



# -- refresh repo
apt-get update

# --- remove error: "Debconf: unable to initialize frontend: Dialog"
apt-get install dialog apt-utils

# -- apt-transport-https requirement for logstash
apt-get install -y apt-transport-https ca-certificates

# -- sdisk available
apt-get install util-linux


# =============================
#  create separate filesystems
# =============================

# stop LXCFS service to avoid file busy errors
systemctl stop lxcfs.service

# (1) /VAR/LOG & /VAR/LIB  partition creation 
echo "****** CREATING /VAR/LOG PART. ******"
# Disklabel type: gpt
# 2 x 2 GB parts, 1 GB available in case of different sector size during review of this script 
# using fdisk interactive
(echo g; echo n; echo 1; echo 2048; echo +2G; echo n; echo 2; echo 4196352; echo +2G; echo w) | fdisk /dev/sdc
# format fs
mkfs.ext4 /dev/sdc1
mkfs.ext4 /dev/sdc2
# bck data 
rsync -a /var/log /tmp
rsync -a /var/lib /tmp
# mount new FS
mount /dev/sdc1 /var/log
mount /dev/sdc2 /var/lib
# delete and move bck data
rm -rf /var/log  2>/dev/null
rm -rf /var/lib  2>/dev/null
# better go runlevel 1 but I haven`t success going back level 5 
# I decide to loose some stats info
rsync -a /tmp/log  /var  1>/dev/null 2>/dev/null
rsync -a /tmp/lib  /var  1>/dev/null 2>/dev/null 
# add info of mounts in /etc/fstab
echo "/dev/sdc1    /var/log   ext4   nodev,nosuid 1 2 " >> /etc/fstab
echo "/dev/sdc2    /var/lib   ext4   nodev,nosuid 1 2 " >> /etc/fstab

      
# (2) SWAP  partition 
echo "****** CREATING SWAP PART. ******"
# using sfdisk and a MBR boot record
echo "start=2048, size=536870912, type=82" > part_def.txt
sfdisk /dev/sdd < part_def.txt
mkswap /dev/sdd1
swapon /dev/sdd1
echo "/dev/sdd1    swap    swap    defaults    0 0 " >> /etc/fstab
echo "start=2048, size=536870912, type=82" > part_def.txt
rm -f part_def.txt

# start LXCFS service because disk partitioning has finished
systemctl start lxcfs.service
