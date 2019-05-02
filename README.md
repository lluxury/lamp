最近打算搭个博客给自己用,发现很久没做lnmp了,所以有了下文:

暂命名为 "一键舒服 01号成果"<br>
根据自己需要,制作了修改版, <br>
增加了 nginx的安装功能,<br>
提供了新的一鍵安装方法.<br>

花了四天时间测试,大约装了几十次, 终于得出一个能用的版本,<br>
虽然我想做到更广泛的兼容,但目前没有那个精力,也没有相应的时间.<br>
<br>
所以个人建议如下, 和我选一样的环境:<br>
就下面的**蓝色**条幅链接,两个里挑一个即可.<br>
<br>
&nbsp;&nbsp;&nbsp;&nbsp; 这是主机厂商的推广, 使用后会给你和我各10刀,<br>
&nbsp;&nbsp;&nbsp;&nbsp; 没有啥负作用.当然,自己有服务器用自己的也可以,<br>
&nbsp;&nbsp;&nbsp;&nbsp; 虽然上面印的2.5刀一个月,不过是没ipv4的服务器,<br> 
&nbsp;&nbsp;&nbsp;&nbsp; 并且早被抢完,现有的5刀一个月还是比较靠谱的.<br>
<br>
系统选centos7, <br>
然后把我贴在下面的代码直接复制过去用就好: <br>
<br>
https://www.vultr.com/?ref=7997492 <br>
<a href="https://www.vultr.com/?ref=7997492"><img src="https://www.vultr.com/media/banner_2.png" width="468" height="60"></a>
<br>
```bash
cd ~
yum -y install wget git tmux
git clone https://github.com/lluxury/lamp.git
cd lamp
chmod 755 *.sh

cmd=$(which tmux) # tmux path
session=lamp
$cmd has -t $session

if [ $? != 0 ]; then
  $cmd new -d -n f21 -s $session "cd ~/lamp && /usr/bin/sh ~/lamp/lamp.sh --apache_option 2 --apache_modules 4 --db_option 3 \
  --db_root_pwd lamp.sh --php_option 3 --php_extensions 14 --phpmyadmin_option 2 --kodexplorer_option 2
"
fi

tmux a
```
<a href="https://www.vultr.com/?ref=7997493-4F"><img src="https://www.vultr.com/media/banner_2.png" width="468" height="60"></a>
<br>
附赠一个部署wordpress 博客的语句:<br>
<br>
```bash
wget https://wordpress.org/wordpress-5.0.3.tar.gz
tar zxvf wordpress-5.0.3.tar.gz 
mv wordpress /data/www/
cd /data/www/
mv default/ lamp_bak
mv wordpress default
chown www.www default/

wget https://downloads.wordpress.org/plugin/wp-statistics.12.6.4.zip
yum install -y unzip
unzip wp-statistics.12.6.4.zip 
mv wp-statistics/ /data/www/default/wp-content/plugins/


wget https://downloads.wordpress.org/plugin/weichuncai.zip
unzip weichuncai.zip 
mv weichuncai /data/www/default/wp-content/plugins/

```

<br>
部署完之后,登陆服务器,键入以下3句命令即可:<br>
<br>

```bash
mysql -p
Enter password: 输入 lamp.sh
create database wp
```

<br>
<br>

然后通过浏览器输入服务器的ip地址,进入wp的部署环节.<br>
当然,这样数据库会有风险, 稍后会提供一个生成随机密码的功能.<br>


<div align="center">
    <a href="https://lamp.sh/" target="_blank">
        <img alt="LAMP" src="https://github.com/teddysun/lamp/blob/master/conf/lamp.png">
    </a>
</div>

## Description

[LAMP](https://lamp.sh/) is a powerful bash script for the installation of Apache + PHP + MySQL/MariaDB/Percona Server and so on. You can install Apache + PHP + MySQL/MariaDB/Percona Server in an very easy way, just need to choose what you want to install before installation. And all things will be done in few minutes.

- [Supported System](#supported-system)
- [Supported Software](#supported-software)
- [Software Version](#software-version)
- [Installation](#installation)
- [Upgrade](#upgrade)
- [Backup](#backup)
- [Uninstall](#uninstall)
- [Default Installation Location](#default-installation-location)
- [Process Management](#process-management)
- [lamp command](#lamp-command)
- [Bugs & Issues](#bugs--issues)
- [License](#license)

## Supported System

- Amazon Linux 2018.03
- CentOS-6.x
- CentOS-7.x (recommend)
- Fedora-29 (recommend)
- Debian-8.x
- Debian-9.x (recommend)
- Ubuntu-14.x
- Ubuntu-16.x
- Ubuntu-18.x (recommend)

## Supported Software

- Apache-2.4 (Include HTTP/2 module: [nghttp2](https://github.com/nghttp2/nghttp2), [mod_http2](https://httpd.apache.org/docs/2.4/mod/mod_http2.html))
- Apache Additional Modules: [mod_wsgi](https://github.com/GrahamDumpleton/mod_wsgi), [mod_security](https://github.com/SpiderLabs/ModSecurity), [mod_jk](https://tomcat.apache.org/download-connectors.cgi)
- MySQL-5.5, MySQL-5.6, MySQL-5.7, MySQL-8.0, MariaDB-5.5, MariaDB-10.0, MariaDB-10.1, MariaDB-10.2, MariaDB-10.3, Percona-Server-5.5, Percona-Server-5.6, Percona-Server-5.7, Percona-Server-8.0
- PHP-5.6, PHP-7.0, PHP-7.1, PHP-7.2, PHP-7.3
- PHP Additional extensions: Zend OPcache, [ionCube Loader](https://www.ioncube.com/loaders.php), [XCache](https://xcache.lighttpd.net/), [imagick](https://pecl.php.net/package/imagick), [gmagick](https://pecl.php.net/package/gmagick), [libsodium](https://github.com/jedisct1/libsodium-php), [memcached](https://github.com/php-memcached-dev/php-memcached), [redis](https://github.com/phpredis/phpredis), [mongodb](https://pecl.php.net/package/mongodb), [swoole](https://github.com/swoole/swoole-src), [yaf](https://github.com/laruence/yaf), [xdebug](https://github.com/xdebug/xdebug)
- Other Software: [OpenSSL](https://github.com/openssl/openssl), [ImageMagick](https://github.com/ImageMagick/ImageMagick), [GraphicsMagick](http://www.graphicsmagick.org/), [Memcached](https://github.com/memcached/memcached), [phpMyAdmin](https://github.com/phpmyadmin/phpmyadmin), [Redis](https://github.com/antirez/redis), [KodExplorer](https://github.com/kalcaddle/KodExplorer)

## Software Version

| Apache & Additional Modules | Version                                        |
|-----------------------------|------------------------------------------------|
| httpd                       | 2.4.39                                         |
| apr                         | 1.7.0                                          |
| apr-util                    | 1.6.1                                          |
| nghttp2                     | 1.38.0                                         |
| openssl                     | 1.1.1b                                         |
| mod_wsgi                    | 4.6.5                                          |
| mod_security2               | 2.9.3                                          |
| mod_jk                      | 1.2.46                                         |

| Database                    | Version                                        |
|-----------------------------|------------------------------------------------|
| MySQL                       | 5.5.62, 5.6.44, 5.7.26, 8.0.16                 |
| MariaDB                     | 5.5.63, 10.0.38, 10.1.38, 10.2.23, 10.3.14     |
| Percona-Server              | 5.5.62-38.14, 5.6.43-84.3, 5.7.25-28, 8.0.15-5 |

| PHP & Additional extensions | Version                                        |
|-----------------------------|------------------------------------------------|
| PHP                         | 5.6.40, 7.0.33, 7.1.28, 7.2.17, 7.3.4          |
| ionCube Loader              | 10.3.4                                         |
| XCache(PHP 5.6 only)        | 3.2.0                                          |
| ImageMagick                 | 7.0.8-39                                       |
| imagick extension           | 3.4.3                                          |
| GraphicsMagick              | 1.3.31                                         |
| gmagick extension(PHP 5.6)  | 1.1.7RC3                                       |
| gmagick extension(PHP 7)    | 2.0.5RC1                                       |
| libsodium                   | 1.0.17                                         |
| libsodium extension         | 2.0.21                                         |
| memcached                   | 1.5.12                                         |
| libmemcached                | 1.0.18                                         |
| memcached extension(PHP 5.6)| 2.2.0                                          |
| memcached extension(PHP 7)  | 3.1.3                                          |
| redis                       | 5.0.4                                          |
| redis extension(PHP 5.6)    | 2.2.8                                          |
| redis extension(PHP 7)      | 4.3.0                                          |
| mongodb extension           | 1.5.3                                          |
| swoole extension(PHP 7 only)| 4.3.3                                          |
| yaf extension(PHP 7 only)   | 3.0.8                                          |
| xdebug extension(PHP 5.6)   | 2.5.5                                          |
| xdebug extension(PHP 7)     | 2.7.1                                          |
| phpMyAdmin                  | 4.8.5                                          |
| KodExplorer                 | 4.35                                           |

## Installation

- If your server system: Amazon Linux/CentOS/Fedora
```bash
yum -y install wget screen git
git clone https://github.com/teddysun/lamp.git
cd lamp
chmod 755 *.sh
screen -S lamp
./lamp.sh
```

- If your server system: Debian/Ubuntu
```bash
apt-get -y install wget screen git
git clone https://github.com/teddysun/lamp.git
cd lamp
chmod 755 *.sh
screen -S lamp
./lamp.sh
```

- [Automation install mode](https://lamp.sh/autoinstall.html)
```bash
~/lamp/lamp.sh -h
```

- Automation install mode example
```bash
~/lamp/lamp.sh --apache_option 1 --apache_modules mod_wsgi,mod_security --db_option 3 --db_root_pwd teddysun.com --php_option 4 --php_extensions ioncube,imagick,redis,mongodb,libsodium,swoole --phpmyadmin_option 1 --kodexplorer_option 1
```

## Upgrade

```bash
cd ~/lamp
git reset --hard         // Resets the index and working tree
git pull                 // Get latest version first
chmod 755 *.sh

./upgrade.sh             // Select one to upgrade
./upgrade.sh apache      // Upgrade Apache
./upgrade.sh db          // Upgrade MySQL/MariaDB/Percona
./upgrade.sh php         // Upgrade PHP
./upgrade.sh phpmyadmin  // Upgrade phpMyAdmin
```

## Backup

- You must modify the config before run it
- Backup MySQL/MariaDB/Percona datebases, files and directories
- Backup file is encrypted with AES256-cbc with SHA1 message-digest (option)
- Auto transfer backup file to Google Drive (need install [gdrive](https://teddysun.com/469.html) command) (option)
- Auto transfer backup file to FTP server (option)
- Auto delete Google Drive's or FTP server's remote file (option)

```bash
./backup.sh
```

## Uninstall

```bash
./uninstall.sh
```

## Default Installation Location

| Apache Location            | Path                                           |
|----------------------------|------------------------------------------------|
| Install Prefix             | /usr/local/apache                              |
| Web root location          | /data/www/default                              |
| Main Configuration File    | /usr/local/apache/conf/httpd.conf              |
| Default Virtual Host conf  | /usr/local/apache/conf/extra/httpd-vhosts.conf |
| Virtual Host location      | /data/www/virtual_host_names                   |
| Virtual Host log location  | /data/wwwlog/virtual_host_names                |
| Virtual Host conf          | /usr/local/apache/conf/vhost/virtual_host.conf |

| phpMyAdmin Location        | Path                                           |
|----------------------------|------------------------------------------------|
| Installation location      | /data/www/default/phpmyadmin                   |

| KodExplorer Location       | Path                                           |
|----------------------------|------------------------------------------------|
| Installation location      | /data/www/default/kod                          |

| PHP Location               | Path                                           |
|----------------------------|------------------------------------------------|
| Install Prefix             | /usr/local/php                                 |
| Configuration File         | /usr/local/php/etc/php.ini                     |
| ini additional location    | /usr/local/php/php.d                           |

| MySQL Location             | Path                                           |
|----------------------------|------------------------------------------------|
| Install Prefix             | /usr/local/mysql                               |
| Data Location              | /usr/local/mysql/data                          |
| my.cnf Configuration File  | /etc/my.cnf                                    |

| MariaDB Location           | Path                                           |
|----------------------------|------------------------------------------------|
| Install Prefix             | /usr/local/mariadb                             |
| Data Location              | /usr/local/mariadb/data                        |
| my.cnf Configuration File  | /etc/my.cnf                                    |

| Percona Location           | Path                                           |
|----------------------------|------------------------------------------------|
| Install Prefix             | /usr/local/percona                             |
| Data Location              | /usr/local/percona/data                        |
| my.cnf Configuration File  | /etc/my.cnf                                    |

## Process Management

| Process     | Command                                                 |
|-------------|---------------------------------------------------------|
| Apache      | /etc/init.d/httpd  (start\|stop\|status\|restart)       |
| MySQL       | /etc/init.d/mysqld (start\|stop\|status\|restart)       |
| MariaDB     | /etc/init.d/mysqld (start\|stop\|status\|restart)       |
| Percona     | /etc/init.d/mysqld (start\|stop\|status\|restart)       |
| Memcached   | /etc/init.d/memcached (start\|stop\|restart)            |
| Redis-Server| /etc/init.d/redis-server (start\|stop\|restart)         |

## lamp Command

| Command    | Description                     |
|------------|---------------------------------|
| lamp add   | create a virtual host           |
| lamp list  | list all virtual host           |
| lamp del   | remove a virtual host           |

## Bugs & Issues

Please feel free to report any bugs or issues to us, email to: i@teddysun.com or [open issues](https://github.com/teddysun/lamp/issues) on Github.

Support(Chinese only): https://lamp.sh/support.html

## License

Copyright (C) 2013 - 2019 [Teddysun](https://teddysun.com/)

Licensed under the [GPLv3](LICENSE) License.
