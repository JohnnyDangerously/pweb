#!/usr/bin/env bash

sudo add-apt-repository -y ppa:nginx/stable
yum update -y
yum upgrade -y
yum install -y nginx build-essential python-dev
pip install flask
pip install uwsgi
sudo mkdir /var/www
sudo mkdir /var/www/demoapp
sudo mkdir /var/www/demoapp/static

sudo chown -R ubuntu:ubuntu /var/www/demoapp/
rm rm /etc/nginx/sites-enabled/default

echo "from flask import Flask
app = Flask(__name__)

@app.route("/")
def hello():
    return "Hello World!"

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=8080)" >  /var/www/demoapp/flasky.py

echo "server {
    listen      80;
    server_name localhost;
    charset     utf-8;
    client_max_body_size 75M;

    location / { try_files $uri @yourapplication; }
    location @yourapplication {
        include uwsgi_params;
        uwsgi_pass unix:/var/www/demoapp/demoapp_uwsgi.sock;
    }
})" >  /var/www/demoapp/demoapp_nginx.conf

sudo ln -s /var/www/demoapp/demoapp_nginx.conf /etc/nginx/conf.d/
sudo /etc/init.d/nginx restart

echo "[uwsgi]
#application's base folder
base = /var/www/demoapp

#python module to import
app = flasky
module = %(app)

#home = %(base)/venv
pythonpath = %(base)

#socket file's location
socket = /var/www/demoapp/%n.sock

#permissions for the socket file
chmod-socket    = 644

#the variable that holds a flask application inside the module imported at line #6
callable = app

#location of log files
logto = /var/log/uwsgi/%n.log" >  /var/www/demoapp/demoapp_uwsgi.ini

sudo mkdir -p /var/log/uwsgi
sudo chown -R ubuntu:ubuntu /var/log/uwsgi

echo "description "uWSGI"
start on runlevel [2345]
stop on runlevel [06]
respawn

env UWSGI=/usr/local/bin/uwsgi
env LOGTO=/var/log/uwsgi/emperor.log

exec $UWSGI --master --emperor /etc/uwsgi/vassals --die-on-term --uid www-data --gid www-data --logto $LOGTO" >  /etc/init/uwsgi.conf

sudo mkdir /etc/uwsgi && sudo mkdir /etc/uwsgi/vassals
sudo ln -s /var/www/demoapp/demoapp_uwsgi.ini /etc/uwsgi/vassals
sudo chown -R www-data:www-data /var/www/demoapp/
sudo chown -R www-data:www-data /var/log/uwsgi/

sudo start usgi
sudo start nginx
