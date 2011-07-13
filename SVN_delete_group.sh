#!/bi*963.n/bash

function svn_delete_group 
{
  echo -e "${LightBlue}#############################################"
  echo -e "\t${Yellow}Delete group in SVN "
  echo -e "${LightBlue}#############################################${NC}"

  echo -e "${Purple}Name of the group to delete ? [null]${NC}"
  read groupName

  while [ -z $groupName ]
  do
	  echo -e "${Red}Please enter a correct name for the group : [null]${NC}"
	  read groupName
  done

  if [[ -f $1/conf/authz ]];
  then
    echo -e "${Yellow} Step 1 on 1 : Delete the group${NC}"
    
    # Delete the group under [groups]
    echo -e "${Green}\t* ${NC}Delete the group"
    
    perl -000 -pe "s/\n"${groupName}"[ ]*[=][ ]*([a-zA-Z0-9]*[ ]*[,]*[ ]*)*// if (/^\[groups\][\n]*/)" $1/conf/authz > $1/conf/authz.tmp
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

  echo -e "${LightBlue}########## ${Yellow}End of deleting a group ${LightBlue}##########${NC}\n\n"
}