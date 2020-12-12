#!/bin/bash
#
# (c) Lennart Takanen 
# 
# Docker mysql-database restore and backup tool
# 

helpFunction()
{
   echo ""
   echo "Usage: $0 -u <databaseusername> -p <database password> -n <database name> -c <containerid>"
   echo -e "\t-dbuser Database username"
   echo -e "\t-dbpass Database password"
   echo -e "\t-dbname Database name"
   echo -e "\t-dbhost Database host"
   exit 1 # Exit script after printing help
}

while getopts "c:u:p:n:h:a:" opt
do
   case "$opt" in
      c ) container="$OPTARG" ;;
      u ) dbuser="$OPTARG" ;;
      p ) dbpass="$OPTARG" ;;
      n ) dbname="$OPTARG" ;;
      h ) dbhost="$OPTARG" ;;
      a ) action="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

exportMysqlDocker (){
    docker exec $container /usr/bin/mysqldump -u $dbuser --password=$dbpass $dbname > backup.sql
}
importMysqlDocker (){
    cat backup.sql | docker exec -i $container /usr/bin/mysql -u $dbuser --password=$dbpass $dbname
}

if [ -z "$dbuser"] || [ -z "$dbpass" ] || [ -z "$dbname" ] || [ -z "$container" ]
then
   echo "Some or all of the parameters are empty";
   helpFunction
else 
    echo "$dbuser"
    echo "$dbpass"
    echo "$dbname"
    echo "$container"
    if [ $action == "restore" ]
    then
        importMysqlDocker
        echo "restore"
    else 
        exportMysqlDocker
        echo "backup"
    fi
fi

