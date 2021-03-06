```sh
################################################################################
########################  Building PHP 5.5.31 (PHP-FPM)  #######################
################################################################################

mkdir /opt/php-5.5.31
mkdir -p /usr/local/src/php5-build && cd $_
wget http://de.php.net/get/php-5.5.31.tar.bz2/from/this/mirror -O php-5.5.31.tar.bz2
tar jxf php-5.5.31.tar.bz2
cd php-5.5.31

./configure \
--with-libdir=lib64 \
--prefix=/opt/php-5.5.31 \
--with-pdo-pgsql \
--with-zlib-dir \
--with-freetype-dir \
--enable-mbstring \
--with-libxml-dir=/usr \
--enable-soap \
--enable-calendar \
--with-curl \
--with-mcrypt \
--with-zlib \
--with-gd \
--with-pgsql \
--disable-rpath \
--enable-inline-optimization \
--with-bz2 \
--with-zlib \
--enable-sockets \
--enable-sysvsem \
--enable-sysvshm \
--enable-pcntl \
--enable-mbregex \
--with-mhash \
--enable-zip \
--with-pcre-regex \
--with-mysql \
--with-pdo-mysql \
--with-mysqli \
--with-jpeg-dir=/usr \
--with-png-dir=/usr \
--enable-gd-native-ttf \
--with-openssl \
--with-fpm-user=nginx \
--with-fpm-group=nginx \
--with-libdir=lib \
--enable-ftp \
--with-imap \
--with-imap-ssl \
--with-kerberos \
--with-gettext \
--enable-fpm

make
make test
make install

cp /usr/local/src/php5-build/php-5.5.31/php.ini-production /opt/php-5.5.31/lib/php.ini
cp /opt/php-5.5.31/etc/php-fpm.conf.default /opt/php-5.5.31/etc/php-fpm.conf

/opt/php-5.5.31/etc/php-fpm.conf
>include=/opt/php-5.5.31/etc/pool.d/*.conf  <== ???
>pid = run/php-fpm.pid
>user = apache
>group = apache
>listen = 127.0.0.1:8998


 mkdir -p /opt/php-5.5.31/etc/pool.d


vi /etc/init.d/php-5.5.31-fpm

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#! /bin/sh
### BEGIN INIT INFO
# Provides:          php-5.5.31-fpm
# Required-Start:    $all
# Required-Stop:     $all
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: starts php-5.5.31-fpm
# Description:       starts the PHP FastCGI Process Manager daemon
### END INIT INFO
php_fpm_BIN=/opt/php-5.5.31/sbin/php-fpm
php_fpm_CONF=/opt/php-5.5.31/etc/php-fpm.conf
php_fpm_PID=/opt/php-5.5.31/var/run/php-fpm.pid
php_opts="--fpm-config $php_fpm_CONF"

wait_for_pid () {
        try=0
        while test $try -lt 35 ; do
                case "$1" in
                        'created')
                        if [ -f "$2" ] ; then
                                try=''
                                break
                        fi
                        ;;
                        'removed')
                        if [ ! -f "$2" ] ; then
                                try=''
                                break
                        fi
                        ;;
                esac
                echo -n .
                try=`expr $try + 1`
                sleep 1
        done
}
case "$1" in
        start)
                echo -n "Starting php-fpm "
                $php_fpm_BIN $php_opts
                if [ "$?" != 0 ] ; then
                        echo " failed"
                        exit 1
                fi
                wait_for_pid created $php_fpm_PID
                if [ -n "$try" ] ; then
                        echo " failed"
                        exit 1
                else
                        echo " done"
                fi
        ;;
        stop)
                echo -n "Gracefully shutting down php-fpm "
                if [ ! -r $php_fpm_PID ] ; then
                        echo "warning, no pid file found - php-fpm is not running ?"
                        exit 1
                fi
                kill -QUIT `cat $php_fpm_PID`
                wait_for_pid removed $php_fpm_PID
                if [ -n "$try" ] ; then
                        echo " failed. Use force-exit"
                        exit 1
                else
                        echo " done"
                       echo " done"
                fi
        ;;
        force-quit)
                echo -n "Terminating php-fpm "
                if [ ! -r $php_fpm_PID ] ; then
                        echo "warning, no pid file found - php-fpm is not running ?"
                        exit 1
                fi
                kill -TERM `cat $php_fpm_PID`
                wait_for_pid removed $php_fpm_PID
                if [ -n "$try" ] ; then
                        echo " failed"
                        exit 1
                else
                        echo " done"
                fi
        ;;
        restart)
                $0 stop
                $0 start
        ;;
        reload)
                echo -n "Reload service php-fpm "
                if [ ! -r $php_fpm_PID ] ; then
                        echo "warning, no pid file found - php-fpm is not running ?"
                        exit 1
                fi
                kill -USR2 `cat $php_fpm_PID`
                echo " done"
        ;;
        *)
                echo "Usage: $0 {start|stop|force-quit|restart|reload}"
                exit 1
        ;;
esac

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


chmod 755 /etc/init.d/php-5.5.31-fpm
chkconfig --levels 235 php-5.5.31-fpm on
/etc/init.d/php-5.5.31-fpm start

# if some start problem happened.
netstat -tpln
ps auxf | grep 8998
etc...

## installing some additional modules like APC, memcache, memcached, and ioncube
yum install php-pear
cd /opt/php-5.5.31/etc
pecl -C ./pear.conf update-channels

pecl -C ./pear.conf install apc
vi /opt/php-5.5.31/lib/php.ini
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
extension=apc.so
apc.enabled=1
apc.shm_size=128M
apc.ttl=0
apc.user_ttl=600
apc.gc_ttl=600
apc.enable_cli=1
apc.mmap_file_mask=/tmp/apc.XXXXXX
;apc.mmap_file_mask=/dev/zero
;apc.shm_segments = 5
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

pecl -C ./pear.conf install memcache

vi /opt/php-5.5.31/lib/php.ini
>extension=memcache.so


yum install libmemcached-devel
pecl -C ./pear.conf install memcached

vi /opt/php-5.5.31/lib/php.ini
>extension=memcached.so

cd /tmp

# The ionCube Loader can be installed as follows:
wget http://downloads2.ioncube.com/loader_downloads/ioncube_loaders_lin_x86.tar.gz
tar xfvz ioncube_loaders_lin_x86.tar.gz

cp ioncube/ioncube_loader_lin_5.5.so /opt/php-5.5.31/lib/php/extensions/no-debug-non-zts-20121212/ioncube.so
vi /opt/php-5.5.31/lib/php.ini
(before the [PHP] line):
>zend_extension = /opt/php-5.5.31/lib/php/extensions/no-debug-non-zts-20121212/ioncube.so

/etc/init.d/php-5.5.31-fpm reload
<<<<<<< HEAD
```
=======
>>>>>>> b13c58033df47de62e7317a36158973eb4ed5d03
