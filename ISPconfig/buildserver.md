<<<<<<< HEAD
```sh
=======
https://www.howtoforge.com/perfect-server-centos-6.4-x86_64-apache2-dovecot-ispconfig-3-p4

>>>>>>> b13c58033df47de62e7317a36158973eb4ed5d03
//********************************
# Notworking konfiguration
ifconfig
vi /etc/resolv.conf
vi /etc/sysconfig/network
vi /etc/hosts

# Configure The Firewall
iptables -L

# Disable SELinux
vi /etc/selinux/config
reboot

# Enable Additional Repositories And Install Some Software
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY*
rpm --import http://dag.wieers.com/rpm/packages/RPM-GPG-KEY.dag.txt
cd /tmp
wget http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el6.rf.i686.rpm
rpm -ivh rpmforge-release-0.5.3-1.el6.rf.i686.rpm
# or
rpm --import https://fedoraproject.org/static/0608B895.txt
wget http://dl.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm
rpm -ivh epel-release-6-8.noarch.rpm

vi /etc/yum.repos.d/epel.repo
> priority=10

yum update

<<<<<<< HEAD
=======

>>>>>>> b13c58033df47de62e7317a36158973eb4ed5d03
# Quota
yum install quota
vi /etc/fstab
> /dev/mapper/vg_web-lv_home /home                   ext4    usrjquota=aquota.user,grpjquota=aquota.group,jqfmt=vfsv0        1 2
mount -o remount /home

# Install Apache, MySQL, phpMyAdmin
yum install ntp httpd mod_ssl mysql-server php php-mysql php-mbstring phpmyadmin

# Install Dovecot
yum install dovecot dovecot-mysql
chkconfig --levels 235 dovecot on
/etc/init.d/dovecot start

# Install Postfix
yum install postfix
chkconfig --levels 235 sendmail off
/etc/init.d/sendmail stop
chkconfig --levels 235 postfix on
/etc/init.d/postfix restart

# Install Getmail
yum install getmail

# Set MySQL Passwords And Configure phpMyAdmin
chkconfig --levels 235 mysqld on
/etc/init.d/mysqld start
mysql_secure_installation
Af2j9_Ov]YjT6XB

vi /etc/httpd/conf.d/phpmyadmin.conf
???

vi /usr/share/phpmyadmin/config.inc.php
> $cfg['Servers'][$i]['auth_type'] = 'http';

chkconfig --levels 235 httpd on
/etc/init.d/httpd start

# Install Amavisd-new, SpamAssassin And ClamAV
yum install amavisd-new spamassassin clamav clamd unzip bzip2 unrar perl-DBD-mysql

sa-update
chkconfig --levels 235 amavisd on
chkconfig --del clamd
chkconfig --levels 235 clamd.amavisd on
/usr/bin/freshclam
/etc/init.d/amavisd start
/etc/init.d/clamd.amavisd start


<<<<<<< HEAD
#!!!!
=======
!!!!



>>>>>>> b13c58033df47de62e7317a36158973eb4ed5d03

# Install Ruby
yum install httpd-devel ruby ruby-devel

cd /tmp
wget http://fossies.org/unix/www/apache_httpd_modules/mod_ruby-1.3.0.tar.gz
tar zxvf mod_ruby-1.3.0.tar.gz
cd mod_ruby-1.3.0/
./configure.rb --with-apr-includes=/usr/include/apr-1
make
make install

vi /etc/httpd/conf.d/ruby.conf
>LoadModule ruby_module modules/mod_ruby.so
>RubyAddPath /1.8

/etc/init.d/httpd restart


# Install mod_python
yum install mod_python

/etc/init.d/httpd restart


# Additional PHP Versions
# Install the prerequisites for building PHP
# https://www.howtoforge.com/how-to-use-multiple-php-versions-php-fpm-and-fastcgi-with-ispconfig-3-centos-6.3

yum groupinstall 'Development Tools'
yum install libxml2-devel libXpm-devel gmp-devel libicu-devel t1lib-devel aspell-devel openssl-devel bzip2-devel \
libcurl-devel libjpeg-devel libvpx-devel libpng-devel freetype-devel readline-devel libtidy-devel libxslt-devel  \
libmcrypt-devel pcre-devel curl-devel mysql-devel ncurses-devel gettext-devel net-snmp-devel libevent-devel      \
libtool-ltdl-devel libc-client-devel postgresql-devel

Building_5.4.45_PHP_FPM.man
Building_5.5.31_PHP_FPM.man
Building_5.6.17_PHP_FPM.man


# Install PureFTPd
yum install pure-ftpd

chkconfig --levels 235 pure-ftpd on
/etc/init.d/pure-ftpd start

yum install openssl

vi /etc/pure-ftpd/pure-ftpd.conf
>TLS                      1

mkdir -p /etc/ssl/private/

openssl req -x509 -nodes -days 7300 -newkey rsa:2048 -keyout /etc/ssl/private/pure-ftpd.pem -out /etc/ssl/private/pure-ftpd.pem

chmod 600 /etc/ssl/private/pure-ftpd.pem

 /etc/init.d/pure-ftpd restart

# Install BIND
yum install bind bind-utils

vi /etc/sysconfig/named
#ROOTDIR=/var/named/chroot

cp /etc/named.conf /etc/named.conf_bak
cat /dev/null > /etc/named.conf

vi /etc/named.conf
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
// named.conf
//
// Provided by Red Hat bind package to configure the ISC BIND named(8) DNS
// server as a caching only nameserver (as a localhost DNS resolver only).
//
// See /usr/share/doc/bind*/sample/ for example named configuration files.
//
options {
        listen-on port 53 { any; };
        listen-on-v6 port 53 { any; };
        directory       "/var/named";
        dump-file       "/var/named/data/cache_dump.db";
        statistics-file "/var/named/data/named_stats.txt";
        memstatistics-file "/var/named/data/named_mem_stats.txt";
        allow-query     { any; };
        recursion no;
        allow-recursion { none; };
};
logging {
        channel default_debug {
                file "data/named.run";
                severity dynamic;
        };
};
zone "." IN {
        type hint;
        file "named.ca";
};
include "/etc/named.conf.local";
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

touch /etc/named.conf.local

chkconfig --levels 235 named on
/etc/init.d/named start


# Install Webalizer, And AWStats
yum install webalizer awstats perl-DateTime-Format-HTTP perl-DateTime-Format-Builder


# Install Jailkit
cd /tmp
wget http://olivier.sessink.nl/jailkit/jailkit-2.19.tar.gz
tar xvfz jailkit-2.19.tar.gz
cd jailkit-2.19
./configure
make
make install
cd ..
rm -rf jailkit-2.19*


# Install fail2ban
yum install fail2ban

vi /etc/fail2ban/fail2ban.conf
>#logtarget = SYSLOG
>logtarget = /var/log/fail2ban.log

# Install rkhunter
yum install rkhunter

# Install Mailman
yum install mailman

/usr/lib/mailman/bin/newlist mailman

vi /etc/aliases
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

mailman:              "|/usr/lib/mailman/mail/mailman post mailman"
mailman-admin:        "|/usr/lib/mailman/mail/mailman admin mailman"
mailman-bounces:      "|/usr/lib/mailman/mail/mailman bounces mailman"
mailman-confirm:      "|/usr/lib/mailman/mail/mailman confirm mailman"
mailman-join:         "|/usr/lib/mailman/mail/mailman join mailman"
mailman-leave:        "|/usr/lib/mailman/mail/mailman leave mailman"
mailman-owner:        "|/usr/lib/mailman/mail/mailman owner mailman"
mailman-request:      "|/usr/lib/mailman/mail/mailman request mailman"
mailman-subscribe:    "|/usr/lib/mailman/mail/mailman subscribe mailman"
mailman-unsubscribe:  "|/usr/lib/mailman/mail/mailman unsubscribe mailman"

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

newaliases
/etc/init.d/postfix restart



vi /etc/httpd/conf.d/mailman.conf
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#
#  httpd configuration settings for use with mailman.
#
ScriptAlias /mailman/ /usr/lib/mailman/cgi-bin/
ScriptAlias /cgi-bin/mailman/ /usr/lib/mailman/cgi-bin/
<Directory /usr/lib/mailman/cgi-bin/>
    AllowOverride None
    Options ExecCGI
    Order allow,deny
    Allow from all
</Directory>

#Alias /pipermail/ /var/lib/mailman/archives/public/
Alias /pipermail /var/lib/mailman/archives/public/
<Directory /var/lib/mailman/archives/public>
    Options Indexes MultiViews FollowSymLinks
    AllowOverride None
    Order allow,deny
    Allow from all
    AddDefaultCharset Off
</Directory>
# Uncomment the following line, to redirect queries to /mailman to the
# listinfo page (recommended).
# RedirectMatch ^/mailman[/]*$ /mailman/listinfo

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

/etc/init.d/httpd restart

chkconfig --levels 235 mailman on
/etc/init.d/mailman start


# Install SquirrelMail

yum install squirrelmail
/etc/init.d/httpd restart

/usr/share/squirrelmail/config/conf.pl
Command >> <-- D
Command >> <-- dovecot
Press enter to continue... <-- press ENTER
Command >> <--S
Command >> <--Q

vi /etc/squirrelmail/config_local.php
>//$default_folder_prefix                = '';



# Install ISPConfig 3
cd /tmp
wget http://www.ispconfig.org/downloads/ISPConfig-3-stable.tar.gz
tar xfz ISPConfig-3-stable.tar.gz
cd ispconfig3_install/install/

php -q install.php

<<<<<<< HEAD
```
=======
errors postalias: fatal: open /var/lib/mailman/data/aliases: No such file or directory
>>>>>>> b13c58033df47de62e7317a36158973eb4ed5d03
