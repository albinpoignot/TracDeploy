#!/bin/bash

function svn_add_group 
{
  echo -e "${LightBlue}#############################################"
  echo -e "\t${Yellow}Add group in SVN "
  echo -e "${LightBlue}#############################################${NC}"

  echo -e "${Purple}Name of the group ? [null]${NC}"
  read groupName

  while [ -z $groupName ]
  do
    echo -e "${Red}Please enter a correct name for the group : [null]${NC}"
    read groupName
  done

  echo -e "${Purple}Name of the user to add in the group ? [null]${NC}"
  read usersList

  echo -e "${Purple}Add another user to the group - $groupName - ? [y/N]${NC}"
  read again

  if [ -z $again ]
  then
	  again="n"
  fi

  while [ $again != "n" -a $again != "N" ]
  do
    echo -e "${Purple}Name of the user to add in the group ? [null]${NC}"
    read user
    usersList=$usersList","$user

    echo -e "${Purple}Add another user to the group - $groupName - ? [y/N]${NC}"
    read again
    
    if [ -z $again ]
    then
      again="n"
    fi
  done

  # We check if the group already exists
  if [[ -f $1/conf/authz ]];
  then
    echo -e "${Yellow} Step 1 on 1 : Add the new group${NC}"
    
    if [[ -z $(perl -000 -ne 'print if /(\[groups\])/' $1/conf/authz | grep ${groupName}'[ ]*[=][ ]*') ]]; 
    then
      # Add the new group under [groups]
      echo -e "${Green}\t* ${NC}Add the new group and the users list"
      perl -0777 -pe 's/(\[groups\]\n)/\1'${groupName}' = '${usersList}'\n/' $1/conf/authz > $1/conf/authz.tmp
      mv $1/conf/authz.tmp $1/conf/authz
      
      if [[ $? -ne 0 ]];
      then
	echo -e "${Red}\t* An unknown error occurs. Please read before this line. ABORT" 4>&2
	return 4
      fi
    else
      echo -e "${Red}\t* ${NC}The group already exists. If you want to modify it, please delete it and re-create it : nothing changed."
    fi

    echo -e "${LightBlue}--> ${Bold}${Green}Done${NC}\n"
  else
    echo -e "${Red}\t* Can't access to $1/conf/authz. ABORT" 2>&2
    return 2
  fi

  echo -e "${LightBlue}--> ${Bold}${Green}Done${NC}\n"

  echo -e "${LightBlue}########## ${Yellow}End of adding a new group ${LightBlue}##########${NC}\n\n"
}