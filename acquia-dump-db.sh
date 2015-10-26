#!/bin/bash

#Acquia env = dev/test/prod Pass it as qrgument
OPTION=$1
#Path of drupal website docroot, where index.php lies
LOCAL_WEBROOT=add path
SKIP_TABLES=cache,cache_apachesolr,cache_block,cache_content,cache_filter,cache_form,cache_location,cache_menu,cache_mollom,cache_page,cache_rules,cache_swftools,cache_update,cache_views,cache_views_data,boost_cache,boost_cache_relationships,boost_cache_settings,boost_crawler,webform_submissions,webform_submitted_data

cd $LOCAL_WEBROOT/sites/default;

echo Creating local DB backup to tmp/ folder
drush sql-dump --gzip --skip-tables-list=$SKIP_TABLES > /tmp/local_$(date +%Y-%m-%d-%H.%M.%S).sql.gz

echo Dumping DB
#Add acquia account name here after '@'
drush @acquia_website.$OPTION sql-dump --gzip --skip-tables-list=$SKIP_TABLES > /tmp/import_db.sql.gz

echo Importing DB
gunzip /tmp/import_db.sql.gz
drush sql-cli < /tmp/import_db.sql

echo Setting up local modules;
drush dis -y shield;
drush dis -y securepages;
drush en -y views_ui;
drush en -y devel;

echo Configuring local cache settings
drush vset cache 0
drush vset preprocess_css 0
drush vset preprocess_js 0
drush vset page_cache_maximum_age 0
drush vset views_skip_cache TRUE

echo Clearing site cache;
drush cc all;
