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

# Author : Albin POIGNOT
# Version : 0.1
#
# Principal script managing all others "sub-scripts". Please use it
# instead of directly call the other scripts.
#
# Params :
#	- $1 : path of the Trac environment
#	- $2 : path of the SVN repository
#	Please note the two env. can be empty if you planned to
#	execute the "initialisation" script.

#######################################
# Error codes			      #
#   1 -> user should be root	      #
#   2 -> files access problem	      #
#   3 -> error during apache restart  #
#   4 -> unknown error		      #
#   5 -> Trac env error 	      #
#######################################

# Let shell functions inherit ERR trap.
set -o errtrace

# Trigger error when expanding unset variables.
set -o nounset

# Trap error
trap exit_error ERR

function exit_error
{
  echo "${Red}##################################################################"
  echo "${Red}## There is an error during executing the latest script."
  echo "${Red}## Please be careful and check if your system still perennial"
  echo "${Red}## You can read previous lines to get some clues on what happened"
  echo "${Red}##################################################################"
  exit 1
}


# Check if the user is root
if [[ $EUID -ne 0 ]]; then
   echo "$(tput setaf 1)***** This script must be run as root *****" 1>&2
   exit 1
fi

# Import files
source colors.sh

source INIT_init_trac_project.sh
source INIT_packages_installation_sabayon.sh

source TRAC_add.sh
source TRAC_remove.sh

source SVN_add_group.sh
source SVN_delete_group.sh

source SVN_perm_add.sh
source SVN_perm_remove.sh


# Display
echo -e "${LightBlue}#############################################"
echo -e "\t${Yellow}Manage Trac"
echo -e "${LightBlue}#############################################${NC}"

while [[ 1 ]]
do
  action=""
  while [[ -z $action ]]
  do
    echo -e "${Purple}What do you want to do ? [null]${NC}"
    echo -en "${NC}${Brown}"
    echo "1 : Verify the installation of the packages"
    echo "2 : Initialize a new Trac environment"
    echo "3 : Add a new user to Trac"
    echo "4 : Add a new group to Trac"
    echo "5 : Remove a user to Trac"
    echo "6 : Remove a group to Trac"
    echo "7 : Add a group to SVN"
    echo "8 : Remove a group to SVN"
    echo "9 : Allow a user to access to a SVN directory"
    echo "10 : Allow a group to access to a SVN directory"
    echo "11 : Remove authorizations to a user on a SVN directory"
    echo "12 : Remove authorizations to a group on a SVN directory"
    echo "0 : Quitter"
    
    echo -n "Action :${NC} "
    read action
  done

  echo -e "${NC}"

  case "$action" in
    "1" ) init_packages_sabayon;;
    "2" ) init_trac_project $1 $2;;
    "3" ) trac_add $1 u;;
    "4" ) trac_add $1 g;; 
    "5" ) trac_remove $1 u;;
    "6" ) trac_remove $1 g;;
    "7" ) svn_add_group $2;;
    "8" ) svn_delete_group $2;;
    "9" ) svn_perm_add $2 u;;
    "10" ) svn_perm_add $2 g;;
    "11" ) svn_perm_remove $2 u;;
    "12" ) svn_perm_remove $2 g;;
    "0" ) echo -e "${LightBlue}\n\n--> ${Green}Good bye :)${NC}\n" 
	    exit 0;;
  esac

  case "$?" in
    "1" ) echo "${Red}User should be root !"
	  exit 1;;
    "2" ) echo "${Red}Error about file access."
	  exit 1;;
    "3" ) echo "${Red}There is an error with Apache."
	  exit 1;;
    "4" ) echo "${Red}Unknown error !"
	  exit 1;;
    "5" ) echo "${Red}Error accessing Trac environment"
	  exit 1;;
    "6" ) echo "${Red}There is an error during adding the user in access file"
	  exit 1;;
  esac

done
