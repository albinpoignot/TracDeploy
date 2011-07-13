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


echo -e "\033[32m ##########################################################"
echo -e "\033[32m #          Installation des dépendances de Trac          #"
echo -e "\033[32m ##########################################################"

# 1. Mettre à jour l'arbre des paquets ?
echo -e "\033[33m Voulez-vous mettre à jour l'abre avant l'installation (Y/n) ?"
read answ
if [ -z $answ ];
then
	answ="y"
fi

if [ $answ != "n" -a "N" ];
then
	echo -e "\033[32m ********** Mise à jour de l'arbre (1/9) **********"
	echo -e "\033[0m "
	emerge -q --sync
	echo -e "\033[1;32m -- Termine --"
fi

# Emerge options (pour info) :
# --noreplace (-n) : ne ré-installe pas un package déjà installé
# --newuse (-N) : inclut les packages ou le flag USE a ete mis a jour

# 2. Python
echo -e "\033[0;32m ********** Installation de Python (2/9) **********"
emerge -qNu dev-lang/python
echo -e "\033[1;32m -- Terminé --"

# 3. SVN and Python's SVN module
echo -e "\033[0;32m ********** Installation de SVN (3/9) **********"
flaggie dev-vcs/subversion +apache2
emerge -qNu dev-vcs/subversion
#emerge -qNu dev-python/pysvn
echo -e "\033[1;32m -- Terminé --"

# 4. apache2 & mod_python for apache (pas de config)
echo -e "\033[0;32m ********** Installation de Apache & mod_python (4/9) **********"
emerge -qNu www-servers/apache
emerge -qNu www-apache/mod_python
echo -e "\033[1;32m -- Terminé --"

# 5. Genshi & setuptools (setuptools est installé en tant que dépendance de Genshi)
echo -e "\033[0;32m ********** Installation de Genshi (5/9) **********"
emerge -qNu dev-python/genshi
echo -e "\033[1;32m -- Terminé --"

# 6. SQLite & le module SQLite pour Python
echo -e "\033[0;32m ********** Installation de SQLite & SQLite pour Python (6/9) **********"
emerge -qNu dev-db/sqlite dev-python/pysqlite
echo -e "\033[1;32m -- Terminé --"

# 7. Babel (pour avoir un system Trac multi-langue)
echo -e "\033[0;32m ********** Installation de Babel (7/9) **********"
emerge -qNu dev-python/Babel
echo -e "\033[1;32m -- Terminé --"

# 8. Trac (avec les flags Subversion et SQLite)
echo -e "\033[0;32m ********** Installation de Trac (8/9) **********"
flaggie www-apps/trac +subversion +sqlite
emerge -qNu trac
echo -e "\033[1;32m -- Terminé --"

# 9. Configuration d'Apache2 : Activation mod_python, DAV & SVN
echo -e "\033[0;32m ********** Configuration d'Apache (9/9) **********"

echo -e "\033[32m      > Activation de mod_python "
if [[ -z $(cat /etc/conf.d/apache2 | grep APACHE2_OPTS | grep PYTHON) ]]; then
  sed 's/APACHE2_OPTS="/APACHE2_OPTS="-D PYTHON /' /etc/conf.d/apache2 > /etc/conf.d/apache2.tmp && mv /etc/conf.d/apache2.tmp /etc/conf.d/apache2
fi

if [[ -z $(cat /etc/conf.d/apache2 | grep APACHE2_OPTS | grep SVN) ]]; then
  sed 's/APACHE2_OPTS="/APACHE2_OPTS="-D SVN /' /etc/conf.d/apache2 > /etc/conf.d/apache2.tmp && mv /etc/conf.d/apache2.tmp /etc/conf.d/apache2
fi

if [[ -z $(cat /etc/conf.d/apache2 | grep APACHE2_OPTS | grep SVN_AUTHZ) ]]; then
  sed 's/APACHE2_OPTS="/APACHE2_OPTS="-D SVN_AUTHZ /' /etc/conf.d/apache2 > /etc/conf.d/apache2.tmp && mv /etc/conf.d/apache2.tmp /etc/conf.d/apache2
fi

if [[ -z $(cat /etc/conf.d/apache2 | grep APACHE2_OPTS | grep DAV) ]]; then
  sed 's/APACHE2_OPTS="/APACHE2_OPTS="-D DAV /g' /etc/conf.d/apache2 > /etc/conf.d/apache2.tmp && mv /etc/conf.d/apache2.tmp /etc/conf.d/apache2
fi
echo -e "\033[1;32m -- Terminé --"

hn=$(hostname)
if [[ -n $(cat /etc/hosts | grep $(hostname)) ]]; then
	echo -e "\033[32m      > Ajout de cet ordinateur dans /etc/hosts"
	echo "# Configuration pour Apache" >> /etc/hosts
	echo "127.0.0.1 " $hn >> /etc/hosts
	echo -e "\033[1;32m -- Termine --"
else
	echo -e "\033[32m      > Ordinateur déjà ajouté dans /etc/hosts"
fi

if [[ -z $(cat /etc/apache2/httpd.conf | grep $(hostname)) ]]; then
	echo -e "\033[32m      > Ajout de cet ordinateur dans /etc/apache2/httpd.conf"
	echo "ServerName " $hn >> /etc/apache2/httpd.conf
	echo -e "\033[1;32m -- Terminé --"
else
	echo -e "\033[32m      > Ordinateur déjà ajouté dans /etc/apache2/httpd.conf"
fi
