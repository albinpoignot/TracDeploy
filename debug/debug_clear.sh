#!/bin/bash

# This script delete everything in /home/trac then copy back the back up of 
# /etc/apache2/vhosts.d/default_vhost.include

rm -r /home/trac
rm -r /home/svnRepos

#mkdir /home/svnRepos
#mkdir /home/trac

rm /etc/apache2/vhosts.d/default_vhost.include
cat /etc/apache2/vhosts.d/default_vhost.include.BACKUP >> /etc/apache2/vhosts.d/default_vhost.include
/etc/init.d/apache2 restart


