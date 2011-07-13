#!/bin/bash

function trac_add
{

  if [[ $2 = "u" ]];
  then
    display="user"
  else
    display="group"
  fi

  echo -e "${LightBlue}#############################################"
  echo -e "\t${Yellow}Add new ${display} in Trac"
  echo -e "${LightBlue}#############################################${NC}"

  echo -e "${Purple}Name of the ${display} ? [null]${NC}"
  read userName

  while [ -z $userName ]
  do
    echo -e "${Red}Please enter a correct name for the ${display} : [null]${NC}"
    read userName
  done

  if [[ $2 = "u" ]];
  then
    pass1="1"
    pass2="2"
    while [ $pass1 != $pass2 ]
    do
      echo -ne "${Purple}Enter a password for $userName : [null]${NC}"
      stty -echo
      read pass1
      stty echo
      echo -e "\n"

      while [ -z $pass1 ]
      do
	echo -ne "${Red}Please enter a correct password for $userName : [null] (at least 1 character)${NC}"
	stty -echo
	read pass1
	stty echo
	echo -e "\n"
      done
      
      echo -ne "${Purple}Please enter it again : [null]${NC}"
      stty -echo
      read pass2
      stty echo
      echo -e "\n"

      if [ $pass1 != $pass2 ]
      then
	echo -e "${Red}Error : the two passwords are not matching !${NC}"
      fi
    done
  fi


  echo -e "${Yellow} Step 1 on 1 : Adding ${display} in Trac${NC}"
  
  echo -e "${Green}\t* ${NC}Add the ${display} in the Trac environment"
  trac-admin $1 permission add $userName anonymous > /dev/null 2>&1
  
  if [[ $? -eq 0 ]];
  then
    return 5
  fi

  if [[ $2 = "u" ]];
  then
    echo -e "${Green}\t* ${NC}Add the user in the htpasswd file"
    htpasswd2 -b $1/passwords.passwd $userName $pass1 > /dev/null 2>&1
    
#     if [[ $? -eq 0 ]];
#     then
#       if [[ $? -eq 1 ]]:
#       then
# 	return 2
#       else
# 	return 6
#       fi
# 
#       trac-admin $1 permission remove $userName * > /dev/null 2>&1
# 
#     fi

  else
    echo -e "${Yellow}\t* ${NC}Do not need to add the group in the htpasswd file"
  fi

  echo -e "${LightBlue}--> ${Bold}${Green}Done${NC}\n"

  echo -e "${Yellow}* ${NC}"
  echo -e "${Yellow}* ${NC}Warning"
  echo -e "${Yellow}* ${NC}Please remember to edit permissions in your Trac environment"
  echo -e "${Yellow}* ${NC}"

  echo -e "${LightBlue}########## ${Yellow}End of adding a ${display} ${LightBlue}##########${NC}\n\n"

  return 0

}
