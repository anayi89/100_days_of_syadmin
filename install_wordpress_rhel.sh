#!/bin/bash
# Update the OS.
yum update -y

# Install Apache and MySQL.
yum install -y httpd mariadb mariadb-server

# Configure the firewall to allow HTTP & HTTPS traffic.
firewall_array=('--add-service=http --zone=public --permanent' '--add-service=https --zone=public --permanent' '--reload')
for i in ${apache_array[@]}
do
    firewall-cmd $i
done

# Start Apache.
apache_array=('enable' 'start' '--no-pager status')
for i in ${apache_array[@]}
do
    systemctl $i httpd
done

# Start MySQL.
apache_array=('enable' 'start' '--no-pager status')
for i in ${apache_array[@]}
do
    systemctl $i mariadb
done

# Secure MySQL and configure it for Wordpress.
echo 'Enter a root password for MySQL:'
read -r -s "mysql_pass"

echo 'Enter a username for the Wordpress admin account:'
read -r "wp_name"

echo 'Enter a password for the Wordpress admin account:'
read -r -s "wp_pass"

mysql <<_EOF_
UPDATE mysql.user SET Password=PASSWORD('${mysql_pass}') WHERE User='root';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
CREATE DATABASE wordpress;
CREATE USER '${wp_name}'@'localhost' IDENTIFIED BY '${wp_pass}';
GRANT ALL PRIVILEGES ON wordpress.* TO '${wp_name}'@'localhost' IDENTIFIED BY '${wp_pass}';
_EOF_

# Install PHP.
yum install -y php php-mysql php-gd

# Restart the Apache server.
systemctl restart httpd

# Install Wordpress.
my_dir="~/Downloads/"
wp_dir="/var/www/html/"
wget https://wordpress.org/latest.tar.gz -P $my_dir
tar -xvf ${my_dir}latest.tar.gz -C $my_dir
cp -vR ${my_dir}wordpress/* $wp_dir
cp ${wp_dir}wp-config-sample.php ${wp_dir}wp-config.php
chown -R apache:apache ${wp_dir}*

# Configure Wordpress with the MySQL authentication information.
sed -i -e "23s/database_name_here/wordpress/" ${wp_dir}wp-config.php
sed -i -e "26s/username_here/${wp_name}/" ${wp_dir}wp-config.php
sed -i -e "29s/password_here/${wp_pass}/" ${wp_dir}wp-config.php
