#!/usr/bin/env bash

 add-apt-repository -y ppa:nginx/stable
apt-get update -y
apt-get upgrade -y
apt-get install -y nginx build-essential python-dev
pip install flask
pip install uwsgi
 mkdir /var/www
 mkdir /var/www/pweb
# mkdir /var/www/pweb/static

 chown -R ubuntu:ubuntu /var/www/pweb/
rm /etc/nginx/sites-enabled/default

echo "from flask import Flask
app = Flask(__name__)

@app.route(\"/\")
def hello():
    return \"Hello Max!\"

if __name__ == \"__main__\":
    app.run(host='0.0.0.0', port=8080)" >  /var/www/pweb/pweb.py

echo "server {
    listen      80;
    server_name localhost;
    charset     utf-8;
    client_max_body_size 75M;

    location / { try_files \$uri @yourapplication; }
    location @yourapplication {
        include uwsgi_params;
        uwsgi_pass unix:/var/www/pweb/pweb_uwsgi.sock;
    }
    location /static {
        root /var/www/pweb/;
    }
}" >  /var/www/pweb/pweb_nginx.conf

 ln -s /var/www/pweb/pweb_nginx.conf /etc/nginx/conf.d/
 /etc/init.d/nginx restart

echo "[uwsgi]
#application's base folder
base = /var/www/pweb

#python module to import
app = pweb
module = %(app)

#home = %(base)/venv
pythonpath = %(base)

#socket file's location
socket = /var/www/pweb/%n.sock

#permissions for the socket file
chmod-socket    = 644

#the variable that holds a flask application inside the module imported at line #6
callable = app

#location of log files
logto = /var/log/uwsgi/%n.log" >  /var/www/pweb/pweb_uwsgi.ini

 mkdir -p /var/log/uwsgi
 chown -R ubuntu:ubuntu /var/log/uwsgi

echo "description "uWSGI"
start on runlevel [2345]
stop on runlevel [06]
respawn

env UWSGI=/usr/local/bin/uwsgi
env LOGTO=/var/log/uwsgi/emperor.log

exec $UWSGI --master --emperor /etc/uwsgi/vassals --die-on-term --uid www-data --gid www-data --logto $LOGTO" >  /etc/init/uwsgi.conf

 mkdir /etc/uwsgi &&  mkdir /etc/uwsgi/vassals
 ln -s /var/www/pweb/pweb_uwsgi.ini /etc/uwsgi/vassals
 chown -R www-data:www-data /var/www/pweb/
 chown -R www-data:www-data /var/log/uwsgi/

 start uwsgi
 start nginx
