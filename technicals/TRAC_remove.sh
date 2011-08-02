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

function trac_remove
{
  
  if [[ $2 = "u" ]];
  then
    display="user"
  else
    display="group"
  fi

  echo -e "${LightBlue}#############################################"
  echo -e "\t${Yellow}Remove a ${display} in Trac"
  echo -e "${LightBlue}#############################################${NC}"

  echo -e "${Purple}Name of the ${display} ? [null]${NC}"
  read userName

  while [ -z $userName ]
  do
    echo -e "${Red}Please enter a correct name for the ${display} : [null]${NC}"
    read userName
  done

  echo -e "${Yellow} Step 1 on 1 : Removing a ${display} in Trac"
  
  if [[ $2 = "u" ]];
  then
    echo -e "${Green}\t* ${NC}Remove the user in the htpasswd file"
    htpasswd2 -D $1/passwords.passwd $userName

#     if [[ $? -eq 0 ]];
#     then
#       if [[ $? -eq 1 ]]:
#       then
# 	return 2
#       else
# 	return 6
#       fi
#     fi

  else
    echo -e "${Yellow}\t* ${NC}Do not need to edit the htpasswd"
  fi

  echo -e "${Green}\t* ${NC}Remove the ${display} in the environment"
  trac-admin $1 permission remove $userName '*' > /dev/null 2>&1
  

  echo -e "${LightBlue}--> ${Bold}${Green}Done${NC}\n"

  echo -e "${LightBlue}########## ${Yellow}End of removing a ${display} in Trac ${LightBlue}##########${NC}\n\n"

  return 0
}