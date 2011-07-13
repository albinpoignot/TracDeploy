#!/bin/bash

# Copyright 2011 Albin POIGNOT
# 
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
# 
#        http://www.apache.org/licenses/LICENSE-2.0
# 
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.


function init_packages_sabayon
{
  clear
  echo -e "${LightBlue}##########################################################"
  echo -e "\t${Yellow}Install Trac dependancies"
  echo -e "${LightBlue}##########################################################${NC}\n"

  echo -e "${Red}*********\n*\n*\tWARNING\n*"
  echo -e "${Red}* ${NC}This script will unallow Entropy to manage Subversion. Keep it in mind !"
  echo -e "${Red}*\n**********"

  # Step 1 : Update the repos
  echo "${Purple}Do you want to update the repositories before the installation (Entropy AND Portage !) (Y/n) ?${NC}"
  read answ
  if [ -z $answ ]; then
    answ="y"
  fi

  echo -e "${Yellow} Step 1 on 9 : Updating the repositories${NC}"
  if [ $answ != "n" -a "N" ]; then
    equo update --force > /dev/null
    emerge --sync > /dev/null
  else
    echo -e "${Yellow}\t* ${NC}Repository update skipped (asked by user)"
  fi

  echo -e "${LightBlue}--> ${Bold}${Green}Done${NC}\n"


  # Step 2 : Python
  echo -e "${Yellow} Step 2 on 9 : Installation of Python${NC}"
  equo install -q dev-lang/python > /dev/null
  echo -e "${LightBlue}--> ${Bold}${Green}Done${NC}\n"

  # Step 3 : apache2 & mod_python for apache (no config)
  echo -e "${Yellow} Step 3 on 9 : Installation of Apache & mod_python${NC}"
  equo install -q www-servers/apache > /dev/null
  equo install -q www-apache/mod_python > /dev/null
  echo -e "${LightBlue}--> ${Bold}${Green}Done${NC}\n"

  # Step 4 : SVN (by Portage to add +apache2 USE flag...)
  echo -e "${Yellow} Step 4 on 9 : Installation of SVN${NC}"
  echo -e "${Green}\t* ${NC}Install Subversion with Entropy to ensure dependancies"
  equo install dev-vcs/subversion #> /dev/null
  echo -e "${Green}\t* ${NC}Install pkgconfig, needed by future emerge install of Subversion"
  equo install dev-util/pkgconfig #> /dev/null

  echo -e "${Green}\t* ${NC}Back up /etc/portage/packages.use in /etc/portage/packages.use.BACKUP"
  cp /etc/portage/packages.use /etc/portage/packages.use.BACKUP
  
  echo -e "${Green}\t* ${NC}Set 'apache2' flag for Subversion"
  sed 's/\([dev-vcs\/subversion]\)\([-+]*[a-z0-9]*[ ]*\)\(-apache2\)\([-+]*[a-z0-9]*[ ]*\)/\1\2apache2\4/' /etc/portage/packages.use > /etc/portage/packages.use.tmp
  mv /etc/portage/packages.use.tmp /etc/portage/packages.use
  rm /etc/portage/packages.use.tmp
  echo -e "${Green}\t* ${NC}Unallow Entropy to manage Subversion"
  if [[ -z $(cat /etc/entropy/packages/package.mask | grep dev-vcs/subversion) ]]; then
    echo "dev-vcs/subversion" > /etc/entropy/packages/package.mask
  fi

  echo -e "${Green}\t* ${NC}Install Subversion with emerge (--nodeps options enabled)"
  emerge --nodeps dev-vcs/subversion #> /dev/null

  echo -e "${Green}\t* ${NC}Inform Entropy of these updates"
  equo rescue spmsync
  echo -e "${LightBlue}--> ${Bold}${Green}Done${NC}\n"

  # Step 5 : Genshi & setuptools (setuptools is installed as a Genshi's dependancy)
  echo -e "${Yellow} Step 5 on 9 : Installation of Genshi${NC}"
  equo install -q dev-python/genshi > /dev/null
  echo -e "${LightBlue}--> ${Bold}${Green}Done${NC}\n"

  # Step 6 : SQLite & SQLite module for Python
  echo -e "${Yellow} Step 6 on 9 : Installation of SQLite & SQLite for Python${NC}"
  equo install -q dev-db/sqlite > /dev/null
  equo install -q dev-python/pysqlite > /dev/null
  echo -e "${LightBlue}--> ${Bold}${Green}Done${NC}\n"

  # Step 7 : Babel (to have a multi-language Trac system)
  echo -e "${Yellow} Step 7 on 9 : Installation of Babel${NC}"
  equo install -q dev-python/Babel > /dev/null
  echo -e "${LightBlue}--> ${Bold}${Green}Done${NC}\n"

  # Step 8 : Trac
  echo -e "${Yellow} Step 8 on 9 : Installation of Trac${NC}"
  equo install -q www-apps/trac > /dev/null
  echo -e "${LightBlue}--> ${Bold}${Green}Done${NC}\n"

  # Step 9 : Configuration d'Apache2 : Activation mod_python, DAV & SVN
  echo -e "${Yellow} Step 9 on 9 : Configuration of Apache${NC}"

  if [[ -z $(cat /etc/conf.d/apache2 | grep APACHE2_OPTS | grep PYTHON) ]]; then
    echo -e "${Green}\t* ${NC}Activate mod_python in Apache"
    sed 's/APACHE2_OPTS="/APACHE2_OPTS="-D PYTHON /' /etc/conf.d/apache2 > /etc/conf.d/apache2.tmp && mv /etc/conf.d/apache2.tmp /etc/conf.d/apache2
  else
    echo -e "${Yellow}\t* ${NC}mod_python already activated in Apache"
  fi

  if [[ -z $(cat /etc/conf.d/apache2 | grep APACHE2_OPTS | grep SVN) ]]; then
    echo -e "${Green}\t* ${NC}Activate SVN in Apache"
    sed 's/APACHE2_OPTS="/APACHE2_OPTS="-D SVN /' /etc/conf.d/apache2 > /etc/conf.d/apache2.tmp && mv /etc/conf.d/apache2.tmp /etc/conf.d/apache2
  else
    echo -e "${Yellow}\t* ${NC}SVN already activated in Apache"
  fi

  if [[ -z $(cat /etc/conf.d/apache2 | grep APACHE2_OPTS | grep SVN_AUTHZ) ]]; then
    echo -e "${Green}\t* ${NC}Activate SVN authentication in Apache"
    sed 's/APACHE2_OPTS="/APACHE2_OPTS="-D SVN_AUTHZ /' /etc/conf.d/apache2 > /etc/conf.d/apache2.tmp && mv /etc/conf.d/apache2.tmp /etc/conf.d/apache2
  else
    echo -e "${Yellow}\t* ${NC}SVN authentication already activated in Apache"
  fi

  if [[ -z $(cat /etc/conf.d/apache2 | grep APACHE2_OPTS | grep DAV) ]]; then
    echo -e "${Green}\t* ${NC}Activate WebDAV in Apache "
    sed 's/APACHE2_OPTS="/APACHE2_OPTS="-D DAV /g' /etc/conf.d/apache2 > /etc/conf.d/apache2.tmp && mv /etc/conf.d/apache2.tmp /etc/conf.d/apache2
  else
    echo -e "${Yellow}\t* ${NC}WebDAV already activated in Apache"
  fi


  hn=$(hostname)
  if [[ -z $(cat /etc/hosts | grep $(hostname)) ]]; then
    echo -e "${Green}\t* ${NC}Add this computer in /etc/hosts"
    echo "\n# Apache configuration" >> /etc/hosts
    echo "127.0.0.1 " $hn >> /etc/hosts
  else
    echo -e "${Yellow}\t* ${NC}Computer already added in /etc/hosts"
  fi

  if [[ -z $(cat /etc/apache2/httpd.conf | grep $(hostname)) ]]; then
    echo -e "${Green}\t* ${NC}Add this computer in /etc/apache2/httpd.conf"
    echo "ServerName " $hn >> /etc/apache2/httpd.conf
  else
    echo -e "${Yellow}\t* ${NC}Computer already added in /etc/apache2/httpd.conf"
  fi
  echo -e "${LightBlue}--> ${Bold}${Green}Done${NC}\n"

  echo -e "${LightBlue}########## ${Yellow}End of the packages verification ${LightBlue}##########${NC}\n\n"
}
