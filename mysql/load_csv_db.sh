#!/bin/bash

# ===================================================================
# MySQL Database Setup and CSV Data Import Script
# ===================================================================
#
# This script configures the MySQL database and imports product and 
# category data from CSV files into the respective MySQL tables.
# It ensures the database schema is in place, applies AppArmor security 
# settings, downloads the required CSV data files if they don't already 
# exist, and imports the data into the database.
#
# Author: Dmitry Troshenkov (troshenkov.d@gmail.com)
# ===================================================================

# 1. Variables for file paths and MySQL credentials
# ===================================================================
MYSQL_USER="root"
MYSQL_PASSWORD="qwerty"
MYSQL_DATABASE="shop"
GOODS_FILE="/tmp/shop-goods.txt"
CATEGORY_FILE="/tmp/shop-cat.txt"

# 2. Check if script is being run as root
# ===================================================================
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# 3. Apply AppArmor Security Configuration for MySQL
# ===================================================================
echo "Applying AppArmor security rules for MySQL..."

# Check if the AppArmor configuration exists before editing it
if [ ! -f /etc/apparmor.d/usr.sbin.mysqld ]; then
    echo "AppArmor configuration for MySQL not found. Please install and configure AppArmor first."
    exit 1
fi

# Open the AppArmor configuration file for MySQL
echo "Editing AppArmor profile for MySQL..."
cat <<EOF | sudo tee -a /etc/apparmor.d/usr.sbin.mysqld
# Custom AppArmor rules for MySQL
/var/run/mysqld/mysqld.sock w,
/tmp/ r,
/tmp/* rw,
EOF

# Reload AppArmor to apply changes
echo "Reloading AppArmor..."
sudo systemctl reload apparmor

# 4. Download Required Files (Product Data and Categories)
# ===================================================================
echo "Downloading product data and category data..."

# Ensure wget is installed
if ! command -v wget &> /dev/null; then
    echo "wget could not be found, installing..."
    sudo dnf install wget -y
fi

# Download the files only if they don't already exist
if [ ! -f "$GOODS_FILE" ]; then
    wget http://www.linuxcenter.ru/trans/shop-goods.txt -O "$GOODS_FILE"
else
    echo "File $GOODS_FILE already exists, skipping download."
fi

if [ ! -f "$CATEGORY_FILE" ]; then
    wget http://www.linuxcenter.ru/trans/shop-cat.txt -O "$CATEGORY_FILE"
else
    echo "File $CATEGORY_FILE already exists, skipping download."
fi

# 5. MySQL Database Configuration and Data Import
# ===================================================================
echo "Configuring MySQL database and importing data..."

# Check if the database exists, create it if not
mysql --user="$MYSQL_USER" --password="$MYSQL_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;"

# Execute MySQL commands to create necessary tables and import data
/usr/bin/mysql --user="$MYSQL_USER" --password="$MYSQL_PASSWORD" --database="$MYSQL_DATABASE" <<EOFMYSQL
CREATE TABLE IF NOT EXISTS goods (
  id_goods VARCHAR(11) NOT NULL,
  url_goods VARCHAR(500) NOT NULL,
  price INT(11) NOT NULL,
  id_type VARCHAR(11) NOT NULL,
  url_picture VARCHAR(100) NOT NULL,
  url_picture_sm VARCHAR(100) NOT NULL,
  product_name VARCHAR(500) NOT NULL,
  goods_discription TEXT NOT NULL,
  PRIMARY KEY (id_goods)
) ENGINE=MyISAM DEFAULT CHARSET=cp1251;

CREATE TABLE IF NOT EXISTS category (
  id_partition VARCHAR(11) NOT NULL,
  id_parent VARCHAR(11) NOT NULL,
  url_partition VARCHAR(100) NOT NULL,
  name_partition VARCHAR(100) NOT NULL,
  PRIMARY KEY (id_partition)
) ENGINE=MyISAM DEFAULT CHARSET=cp1251;

# Import data from the downloaded files
LOAD DATA LOCAL INFILE '$GOODS_FILE' REPLACE INTO TABLE goods CHARACTER SET cp1251 FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n';
LOAD DATA LOCAL INFILE '$CATEGORY_FILE' REPLACE INTO TABLE category CHARACTER SET cp1251 FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n';
EOFMYSQL

# 6. Clean Up
# ===================================================================
echo "Cleaning up downloaded files..."

# Remove the temporary files after use
rm -f "$GOODS_FILE" "$CATEGORY_FILE"

# 7. Final Cleanup and Exit
# ===================================================================
echo "Database setup and configuration completed successfully."
exit 0
