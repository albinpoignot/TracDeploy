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

function svn_perm_add
{
  if [[ $2 = "u" ]];
  then
    display="user"
  else
    display="group"
  fi

  echo -e "${LightBlue}#############################################"
  echo -e "\t${Yellow}Allow a ${display} to access on a SVN directory"
  echo -e "${LightBlue}#############################################${NC}"

  echo -e "${Purple}Name of the ${display} ? [null]${NC}"
  read userName

  while [[ -z $userName ]]
  do
    echo -e "${Red}Please enter a correct name for the ${display} :${NC}"
    read userName
  done

  echo -e "${Purple}SVN directory to which ${display} can access ? [null]${NC}"
  read dir

  while [[ -z $dir ]]
  do
    echo -e "${Red}Please enter a correct directory :${NC}"
    read dir
  done
  
  echo -e "${Purple}Access to grant ? (r or rw)${NC}"
  read perm
  perm='n'
  while [[ $perm != 'r' && $perm != 'rw' ]]
  do
    echo -e "${Red}Please enter a correct access :${NC}"
    read perm
  done

  # Check if the directory already exists in the perm file
  if [[ -f $1/conf/authz ]];
  then
    echo -e "${Yellow} Step 1 on 1 : Allow the new ${display} to access to ${dir} ${NC}"

    if [[ -z $(cat $1/conf/authz | grep $dir) ]]; then
      # The directory doesn't exist, we create it
      echo -e "${Green}\t* ${NC}Add the new directory and the ${display}"
      
      if [[ $2 = "u" ]];
      then
	echo "[$dir]
	$userName = $perm" >> $1/conf/authz
      else
	echo "[$dir]
	@$userName = $perm" >> $1/conf/authz
      fi
    else

      # The directory already exists, we check if the user is already added
      dir2=$(echo $dir | sed 's/\//\\\//g') # Escape specials chars

      echo -e "${Yellow}\t* ${NC}Directory already exists. Check if ${display} already added."

      if [[ -z $(perl -000 -ne 'print if /['${dir2}']\n/' $1/conf/authz | grep $userName'[ ]*[=][ ]*') ]];
      then
	# We add the user under [$dir]
	echo -e "${Green}\t* ${NC}Add the new ${display} for the directory ${dir}"
	
	if [[ $2 = "u" ]];
	then
	  perl -000 -pe 's/(\['${dir2}'\]\n)/\1'${userName}' = '${perm}'\n/' $1/conf/authz > $1/conf/authz.tmp
	else
	  perl -000 -pe 's/(\['${dir2}'\]\n)/\1@'${userName}' = '${perm}'\n/' $1/conf/authz > $1/conf/authz.tmp
	fi

	mv $1/conf/authz.tmp $1/conf/authz
	
	if [[ $? -ne 0 ]];
	then
	  echo -e "${Red}\t* An unknown error occurs. Please read before this line. ABORT" 4>&2
	  return 4
	fi

      else
	echo -e "${Red}\t* ${NC}Directory and $display already exist. Please delete the user and add it again to modify it."
      fi

    fi
  else
    echo -e "${Red}\t* Can't access to $1/conf/authz. ABORT" 2>&2
    return 2
  fi

  echo -e "${LightBlue}--> ${Bold}${Green}Done${NC}\n"

  echo -e "${LightBlue}########## ${Yellow}End of allow a ${display} to access on a directory${LightBlue}##########${NC}\n\n"
}