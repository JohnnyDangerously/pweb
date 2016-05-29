#!/usr/bin/env bash
ssh ubuntu@ec2-54-201-96-53.us-west-2.compute.amazonaws.com
sudo cd /var/www/
sudo git pull https://github.com/JohnnyDangerously/flasky/
sudo restart uwsgi
sudo restart nginx