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


function init_trac_project
{
  echo -e "${LightBlue}#############################################"
  echo -e "\t${Yellow}Init a new Trac environment"
  echo -e "${LightBlue}#############################################${NC}"

  # -----------------------------------------------------------------------
  # ------------------ Step 1 : Init Trac
  echo -e "${Yellow} Step 1 on 5 : Parameters${NC}"

  # a. Project name
  echo -e "${Purple}What is the name of your project ? [MyProjet]${NC}"
  read projName
  if [ -z $projName ]
  then
	  projName="MyProject"
  fi

  # b. Project path
  projPath=${1}
  if [ -z $projPath ]
  then
    echo -e "${Purple}What is the path of your project ? [null]${NC}"
    read projPath

    while [ -z $projPath ]
    do
      echo -e "${NC}${Red}Please enter a path for your project ? [null]${NC}"
      read projPath
    done
  fi

  pathValid=0
  while [ $pathValid -lt 1 ]
  do
    if [ -d $projPath ]
    then
      nbFiles=$(ls $projPath | wc -l)
      if [[ $nbFiles != "0" ]];
      then
	echo -e "${Red}The installation path is not empty ! Please give another on or finish the process by typing : stop :${NC}"
	read projPath

	if [ $projPath = "stop" ]
	then
	  return 0
	fi
      else
	pathValid=1
      fi
    else
      mkdir -p $projPath
      if [[ $? -ne 0 ]]; then
	echo -e "${Red} * The Trac path can not be created. ABORT${NC}" 2>&2
	return 2
      fi
    fi
  done

  # c. Database path
  echo -e "${NC}${Purple}What is the path of your database ? [db/trac.db]${NC}"
  read dbPath
  if [ -z $dbPath ]
  then
	  dbPath="db/trac.db"
  fi

  # d. Repository
  repoType="svn"

  svnPath=${2}
  if [ -z $svnPath ]
  then
    echo -e "${Purple}What is the path of your SVN repository ? [null]${NC}"
    read svnPath

    while [ -z $svnPath ]
    do
      echo -e "${NC}${Red}Please enter a path for your SVN repository ? [null]${NC}"
      read svnPath
    done
  fi

  # e. First user
  echo -e "${Purple}Enter the Admin's username : [null]${NC}"
  read adminName
  while [ -z $adminName ]
  do
    echo -e "${Red}Please enter a correct Admin's username (at least 1 character) : ${NC}"
    read adminName
  done

  adminPass1="1"
  adminPass2="2"
  while [ $adminPass1 != $adminPass2 ]
  do
    echo -e "${Purple}Enter the Admin's password : [null] ${NC}"
    stty -echo
    read adminPass1
    stty echo
    
    while [ -z $adminPass1 ]
    do
      echo -e "${Red}Please enter a correct Admin's password (at least 1 character) : ${NC}"
      stty -echo
      read adminPass1
      stty echo
    done
    
    echo -e "${Purple}Please enter it a second time : ${NC}"
    stty -echo
    read adminPass2
    stty echo
    
    if [ $adminPass1 != $adminPass2 ]
    then
      echo -e "${Red}Error : The two passwords are not matching ! ${NC}"
    fi
  done

  # f. Configuration of the anonymous user
  echo -e "${Purple}Do you want to disallow Wiki and Tickets access for anonymous users ? [Y/n] ${NC}"
  read anonymousChoice

  # g. Url of the project
  echo -e "${Purple}What URL do you want for your project ? [/trac/"$projName"]${NC}"
  read wantedUrl
  if [ -z $wantedUrl ]
  then
	  wantedUrl="/trac/"$projName
  fi

  # h. Apache restart
  echo -e "${Purple}You will have to restart Apache2. Do you want to restart it automatically ? [Y/n] ${NC}"
  read restartApache

  # -----------------------------------------------------------------------
  # ------------------ Step 2 : Launch the initialisation of SVN repository 
  echo -e "${Yellow} Step 2 on 5 : SVN init${NC}"
  if [ -d $svnPath ]; then
    echo -e "${Yellow}\t* ${NC}SVN repository already exists : skipped"
  else
    echo -e "${Green}\t* ${NC}Create the SVN repository"

    mkdir -p $svnPath
    if [[ $? -ne 0 ]]; then
      echo -e "${Red}\t* ${NC}The SVN path can not be created. ABORT" 2>&2
      return 2
    fi

    svnadmin create $svnPath

    cd $svnPath

    echo -e "${Green}\t* ${NC}Initial import"
    TempDIR=`mktemp -d`

    mkdir -p $TempDIR/trunk
    if [[ $? -ne 0 ]]; then
      rmdir -R $svnPath
      echo -e "${Red}\t* Can not create {$TempDIR}/trunk. ABORT" 2>&2
      exit 1
    fi

    mkdir -p $TempDIR/tags
    if [[ $? -ne 0 ]]; then
      rmdir -R $TempDIR/trunk
      echo -e "${Red}\t* Can not create {$TempDIR}/tags. ABORT" 2>&2
      return 2
    fi

    mkdir -p $TempDIR/branches
    if [[ $? -ne 0 ]]; then
      rmdir -R $svnPath
      rmdir -R $TempDIR/trunk
      rmdir -R $TempDIR/tags
      echo -e "${Red}\t* Can not create {$TempDIR}/branches. ABORT" 2>&2
      return 2
    fi

    svn import -q -m "Initial Import" --non-interactive $TempDIR file://$svnPath

    echo -e "${Green}\t* ${NC}Clear temp files${NC}"
    rmdir $TempDIR/trunk
    rmdir $TempDIR/tags
    rmdir $TempDIR/branches
    rmdir $TempDIR
  fi

  echo -e "${Green}\t* ${NC}Change the files owner${NC}"
  chown -R apache:apache $svnPath

  echo -e "${Green}\t* ${NC}Clean up the authz file to allow futur automatic configs"
  echo -e "[aliases]\n\n[groups]\n\n[/]\n"$adminName" = rw\n" >> $svnPath/conf/authz.tmp && mv $svnPath/conf/authz.tmp $svnPath/conf/authz

  echo -e "${LightBlue}--> ${Bold}${Green}Done${NC}\n"


  # -----------------------------------------------------------------
  # ------------------ Step 3 : Launch the initialisation of Trac env
  echo -e "${Yellow} Step 3 on 5 : Trac init"
  

  echo -e "${Green}\t* ${NC}Initialization of Trac environment"
  if [ -z $svnPath ]
  then
    trac-admin $projPath initenv $projName sqlite:$dbPath >/dev/null
  else
    trac-admin $projPath initenv $projName sqlite:$dbPath $repoType $svnPath >/dev/null
  fi
  echo -e "${LightBlue}--> ${Bold}${Green}Done${NC}\n"


  # ---------------------------------------
  # ------------------ Step 4 : Trac config
  echo -e "${Yellow} Step 4 on 5 : Trac configuration"
  echo -e "${Green}\t* ${NC}Create the permissions file"
  htpasswd2 -cb $projPath/passwords.passwd $adminName $adminPass1 > /dev/null 0>&1

  echo -e "${Green}\t* ${NC}Add the new Admin to the project"
  trac-admin $projPath permission add $adminName TRAC_ADMIN

  if [ -z $anonymousChoice ]
  then
    anonymousChoice="y"
  fi

  if [ $anonymousChoice != "n" -a "N" ]
  then
    echo -e "${Green}\t* ${NC}Disable Wiki and Tickets access for the anonymous user"
    trac-admin $projPath permission remove anonymous WIKI_CREATE WIKIE_MODIFY TICKET_CREATE TICKET_MODIFY
  else
    echo -e "${Yellow}\t* ${NC}Access for Wiki and Tickets access are not disabled"
  fi

  echo -e "${Green}\t* ${NC}Change the files owner"
  chown -R apache:apache $projPath

  echo -e "${LightBlue}--> ${Bold}${Green}Done${NC}\n"

  # -----------------------------------------
  # ------------------ Step 5 : Apache config
  echo -e "${Yellow} Step 5 on 5 : Apache configuration"

  echo -e "${Green}\t* ${NC}Configure Trac access through Apache"
  echo "<Location $wantedUrl>
	  SetHandler mod_python
	  PythonInterpreter main_interpreter
	  PythonHandler trac.web.modpython_frontend
	  PythonOption TracEnv $projPath
	  PythonOption TracUriRoot $wantedUrl
	  PythonOption PYTHON_EGG_CACHE $projPath/egg-cache
	  Order allow,deny
	  Allow from all
  </Location>
	    
  <Location $wantedUrl/login>
	  AuthType Basic
	  AuthName $projName
	  AuthUserFile $projPath/passwords.passwd
	  Require valid-user
  </Location>" >> /etc/apache2/vhosts.d/default_vhost.include
	    
  echo -e "${Green}\t* ${NC}Configure SVN access through Apache"
  echo "<Location $wantedUrl/svn>
	  DAV svn
	  SVNPath $svnPath
	  AuthType Basic
	  AuthName \"$projName SVN\"
	  AuthUserFile $projPath/passwords.passwd
	  AuthzSVNAccessFile $svnPath/conf/authz
	  Require valid-user
  </Location>" >> /etc/apache2/vhosts.d/default_vhost.include

  echo -e "${LightBlue}--> ${Bold}${Green}Done${NC}\n"

  # Restarting Apache
  if [ -z $restartApache ]
  then
    restartApache="y"
  fi

  if [ $restartApache != "n" -a "N" ]
  then
    echo -e "${Green}\t* ${NC}Restarting Apache"
    /etc/init.d/apache2 restart > /dev/null
    if [[ $? -ne 0 ]]; then
      echo -e "${Red}\t* Can not restart Apache. ABORT" 3>&2
      return 3
    fi

    echo -e "${LightBlue}--> ${Bold}${Green}Done${NC}\n"
  else
    echo -e "${Yellow}\t* ${NC}Don't forget to restart Apache"
  fi

  echo -e "${LightBlue}########## ${Yellow}End of the initialization of a new Trac ${LightBlue}##########${NC}\n\n"

  return 0
}
