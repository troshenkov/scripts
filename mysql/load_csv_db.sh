#!/bin/bash

# sudo mcedit/etc/apparmor.d/usr.sbin.mysqld
#/usr/sbin/mysqld {
#...
#/var/run/mysqld/mysqld.sock w,
#/tmp/ r,
#/tmp/* rw,
#}
# sudo /etc/init.d/apparmor reload
#

wget http://www.linuxcenter.ru/trans/shop-goods.txt  -O /tmp/shop-goods.txt
wget http://www.linuxcenter.ru/trans/shop-cat.txt -O /tmp/shop-cat.txt

/usr/bin/mysql --user=root --password=qwerty --database='shop'<<EOFMYSQL 

CREATE TABLE IF NOT EXISTS goods (
  id_goods varchar(11) NOT NULL,
  url_goods varchar(500) NOT NULL,
  price int(11) NOT NULL,
  id_type varchar(11) NOT NULL,
  url_picture varchar(100) NOT NULL,
  url_picture_sm varchar(100) NOT NULL,
  product_name varchar(500) NOT NULL,
  goods_discription varchar(10000) NOT NULL,
  PRIMARY KEY (id_goods)
) ENGINE=MyISAM DEFAULT CHARSET=cp1251;

CREATE TABLE IF NOT EXISTS category (
  id_partition varchar(11) NOT NULL,
  id_parent varchar(11) NOT NULL,
  url_partition varchar(100) NOT NULL,
  name_partition varchar(100) NOT NULL,
  PRIMARY KEY (id_partition)
) ENGINE=MyISAM DEFAULT CHARSET=cp1251;

LOAD DATA LOCAL INFILE '/tmp/shop-goods.txt' REPLACE INTO TABLE goods  CHARACTER SET cp1251 FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n';
LOAD DATA LOCAL INFILE '/tmp/shop-cat.txt' REPLACE INTO TABLE category  CHARACTER SET cp1251 FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n';

EOFMYSQL

rm /tmp/shop-goods.txt
rm /tmp/shop-cat.txt

exit 0
