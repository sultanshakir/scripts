#!/bin/bash

#run level... 1 does not EXEC (TEST RUN FOR DEBUG)... 0 is EXEC (ONLY SET TO 0 IF YOUR READY TO RUN THE SCRIPT FOR REALZ)
level="1"

#vars..NEVER add a trailing slash
site_name="yourdomain.com"
drupal_prod_backup_path="/path/to/yourdomain.com"
drupal_dev_backup_path="/path/to/dev.yourdomain.com"
drush_path="/path/to/drush/drush"
backup_tmp="/path/to/backups/tmp"
dev_db="dev_db"
dev_db_user="dbusername"
dev_db_pass="dbpassword"

#vars do not change...
today=$(date +'%m-%d-%y')

#create backup folder..
echo "Creating dir $backup_tmp/$today..."
if [ "$level" == "0" ]; then
  mkdir $backup_tmp/$today
  chmod -R 777 $backup_tmp/$today
fi
echo "Finished creating backup folder and setting permissions..."

#export prod database...backup
echo "Exporting prod database for ($drupal_prod_backup_path) to ($backup_tmp/$today/$site_name.sql)..."
if [ "$level" == "0" ]; then
  cd $drupal_prod_backup_path
  $drush_path/drush sql-dump --result-file=$backup_tmp/$today/$site_name.sql
fi
echo "Finished exporting prod database..."

#tar prod files...backup just in case
echo "Backing up files $site_name ($backup_tmp/$today/$site_name.tar.gz)"
if [ "$level" == "0" ]; then
  tar -zcf $backup_tmp/$today/$site_name.tar.gz $drupal_prod_backup_path
fi
echo "Finished backing up $site_name files ($site_name.tar.gz)"

#import database to dev..
echo "Importing $site_name.sql into database $dev_db..."
if [ "$level" == "0" ]; then
  mysql -u $dev_db_user -p $dev_db_pass -h localhost $dev_db < $backup_tmp/$today/$site_name.sql
fi
echo "Finished importing $site_name.sql to database $dev_db..."

#copy files from prod to dev..
echo "Copying files from prod to dev..."
if [ "$level" == "0" ]; then
  rm -rf $drupal_dev_backup_path
  cp -a $drupal_prod_backup_path $drupal_dev_backup_path
fi
echo "Done copying files from $drupal_prod_backup_path to $drupal_dev_backup_path"

#DRUPAL STUFF DRUPAL STUFF DRUPAL STUFF

#EDIT SETTINGS.PHP FOR DEV ENVIRONMENT
echo "Edit $drupal_dev_backup_path/sites/default/settings.php"
if [ "$level" == "0" ]; then
  #settings.php location var
  settingsphp = "$drupal_dev_backup_path/sites/default/settings.php"
  #delete comments from settings.php
  sed -i '/\/\*/,/*\//d; /^\/\//d; /^$/d;' $settingsphp
  sed -i '/^\#/d' $settingsphp
  #comment out old db_url...
  sed -i '/$db_url/ s:^://:' $settingsphp
  #TODO: Add new db_url with sed..
fi
echo "Done Editing Settings.php..."

#Drupal Clear Cache...
echo "Clearing Drupal Cache.."
if [ "$level" == "0" ]; then
  cd $drupal_dev_backup_path;
  $drush_path/drush cc all
fi
echo "Done clearing Drupal's cache system..."

#Disable Modules...
echo "Disabling Certain Modules.."
if [ "$level" == "0" ]; then
  cd $drupal_dev_backup_path;
  #$drush_path/drush dis securepages
fi
echo "Done..."


#TODO: Sanatize Data...
