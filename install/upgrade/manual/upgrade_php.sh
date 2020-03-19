#!/bin/bash
​
if [ ! -x "$(command -v php)" ]; then
    echo ""
    echo "PHP is not installed"
    echo ""
    exit 1
fi
​
cur_version=7.3
new_version=7.4
​
echo ""
echo "PHP current: $cur_version"
echo "PHP target : $new_version"
echo "Do you want to upgrade PHP now? [Y|N]"
read upgrade
echo ""
if [ "$upgrade" = "Y" ] || [ "$upgrade" = "y" ]; then
    echo "Process: Upgrading PHP to $new_version"
    echo ""
    cd /tmp
    dpkg-query --showformat='${Package}\t\n' --show | grep php$cur_version > /tmp/cur_packages.txt
    cp -a /tmp/cur_packages.txt /tmp/new_packages.txt
    sed -i "s|$cur_version|$new_version|g" /tmp/new_packages.txt
    apt-get update > /dev/null 2>&1
    apt-get install $(cat /tmp/new_packages.txt)
    update-rc.d php$new_version-fpm defaults
    mv /etc/php/$cur_version/cli/php.ini /etc/php/$new_version/cli/php.ini
    mv /etc/php/$cur_version/fpm/php.ini /etc/php/$new_version/fpm/php.ini
    sed -i "s|$cur_version|$new_version|g" /etc/php/$cur_version/fpm/php-fpm.conf
    mv /etc/php/$cur_version/fpm/php-fpm.conf /etc/php/$new_version/fpm/php-fpm.conf
    rm -rf /etc/php/$new_version/fpm/pool.d
    mkdir -p /etc/php/$new_version/fpm/pool.d
    mv /etc/php/$cur_version/fpm/pool.d/* /etc/php/$new_version/fpm/pool.d
    systemctl stop php$cur_version-php
    apt-get purge $(cat /tmp/cur_packages.txt)
    apt-get clean
    apt-get autoclean
    systemctl restart php$new_version-fpm
    rm -rf /etc/php/$cur_version
    rm -rf /var/lib/php/modules/$cur_version
    rm -rf /tmp/cur_packages.txt
    rm -rf /tmp/new_packages.txt
else
    echo "Process: Aborted"
    echo ""
    exit 0
fi