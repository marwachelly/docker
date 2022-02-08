#!/usr/bin/env bash

cd /var/www/html

/usr/sbin/apache2ctl -D FOREGROUND

cd /etc/apache2/sites-available/

