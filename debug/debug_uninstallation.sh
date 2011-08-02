#!/bin/bash
echo -e "\033[32m * Start of uninstallation"
emerge -C dev-vcs/subversion dev-python/pysvn www-servers/apache www-apache/mod_python dev-python/genshi dev-db/sqlite dev-python/pysqlite dev-python/Babel trac

echo -e "\033[31m ********************************* "
echo "Do you want to clean unused dependencies (y/N) ?"

read depanswer
if [ "$depanswer" = "y" ]; then
	echo -e "\033[32m * Uninstallation of dependencies"
	emerge --depclean
else
	echo -e "\033[32m * Dependencies will not be uninstalled"
fi

echo -e "\033[32m * End of uninstallation"
