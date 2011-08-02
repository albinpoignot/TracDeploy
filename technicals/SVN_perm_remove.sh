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

function svn_perm_remove
{  

  if [[ $2 = "u" ]];
  then
    display="user"
  else
    display="group"
  fi

  echo -e "${LightBlue}#############################################"
  echo -e "\t${Yellow}Unallow a ${display} to access on a SVN directory"
  echo -e "${LightBlue}#############################################${NC}"

  echo -e "${Purple}Name of the ${display} to delete ? [null]${NC}"
  read userName

  while [[ -z $userName ]]
  do
    echo -e "${Red}Please enter a correct name for the ${display} to delete :${NC}"
    read userName
  done

  echo -e "${Purple}SVN directory to which ${display} can't access anymore ? [null]${NC}"
  read dir

  while [[ -z $dir ]]
  do
    echo -e "${Red}Please enter a correct directory :${NC}"
    read dir
  done

  if [[ -f $1/conf/authz ]];
  then

    echo -e "${Yellow} Step 1 on 1 : Delete the new ${display} ${NC}"
    # Delete the user/group under [$dir]
    dir2=$(echo $dir | sed 's/\//\\\//g')
    
    echo -e "${Green}\t* ${NC}Delete the ${display} on ${dir}"

    if [[ $2 = "u" ]];
    then
      perl -000 -pe "s/([\n]"$userName"[ ]*[=][ ]*[rw]*)// if (/^\["$dir2"\][\n]*/)" $1/conf/authz > $1/conf/authz.tmp
    else
      perl -000 -pe "s/([\n][@]"$userName"[ ]*[=][ ]*[rw]*)// if (/^\["$dir2"\][\n]*/)" $1/conf/authz > $1/conf/authz.tmp
    fi
    
    mv $1/conf/authz.tmp $1/conf/authz

#     if [[ $? -ne 0 ]];
#     then
#       echo -e "${Red}\t* An unknown error occurs. Please read before this line. ABORT" 4>&2
#       return 4
#     fi

    echo -e "${LightBlue}--> ${Bold}${Green}Done${NC}\n"

  else
    echo -e "${Red}\t* Can't access to $1/conf/authz. ABORT" 2>&2
    return 2
  fi

  echo -e "${LightBlue}########## ${Yellow}End of unallow a ${display} to access on a directory${LightBlue}##########${NC}\n\n"
}