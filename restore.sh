#!/bin/bash
# Check if the correct number of arguments is provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <backup_archive_filename> <database_dump.sql>"
    exit 1
fi

# Input parameters
backup_file="$1"
database_dump="$2"

# Check the file extension of the backup archive
if [[ "$backup_file" == *.tar.gz ]]; then
    # Restore from a tar.gz archive
    tar -xzvf "$backup_file"
elif [[ "$backup_file" == *.zip ]]; then
    # Restore from a zip archive
    unzip "$backup_file"
elif [[ "$backup_file" == *.tar ]]; then
    # Restore from a tar.gz archive
    tar -xzvf "$backup_file"    
else
    echo "Unsupported archive format. Please provide a .tar.gz or .zip file."
    exit 1
fi

# Check if the archive extraction was successful
if [ $? -ne 0 ]; then
    echo "Failed to extract the backup archive."
    exit 1
fi

# Restore the database using the provided SQL dump


#sed -i "s/$sourceuser/$USER/g" ./wp-config.php

#Set path to the database .sql file
#echo "path to the database .sql file"
#read db_path;

# database variables
db=$(find ./ -type f -name "$database_dump");
newdb="${USER}_$(tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c 6)";
dbpass="$(tr -dc 'a-z0-9' < /dev/urandom | head -c 30)";
database_name=$(grep 'DB_NAME' ./wp-config.php | awk -F"'" {'print $4'});
database_user=$(grep 'DB_USER' ./wp-config.php | awk -F"'" {'print $4'});
database_password=$(grep 'DB_PASS' ./wp-config.php | awk -F"'" {'print $4'});

#replacing database credentials in wp-config.php
sed -i "s/$database_name/$newdb/g" ./wp-config.php;
sed -i "s/$database_user/$newdb/g" ./wp-config.php;
sed -i "s/$database_password/$dbpass/g" ./wp-config.php;
#echo $database_name $database_user $database_password;

echo "> Creating database: ${newdb}";
uapi Mysql create_database name="${newdb}";
echo "> Creating database user: ${newdb} [ ${newdb} ]";
uapi Mysql create_user name="${newdb}" password="${dbpass}";
echo "> Granting database privilleges";
uapi Mysql set_privileges_on_database user="${newdb}" database="${newdb}" privileges=ALL;
 
#importing .sql dump file to the database 

echo "Importing database"
if [ -f "$database_dump" ]; then
    mysql $newdb -u $newdb -p"$dbpass" < $db;
    echo "Database restored successfully from $database_dump"
else
    echo "Please double-check the path to database and run this command if initial import failed: mysql $newdb -u $newdb -p'$dbpass' < /path/to/the/database";
fi



