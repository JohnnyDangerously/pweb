#!/usr/bin/env bash
ssh ubuntu@ec2-54-201-96-53.us-west-2.compute.amazonaws.com <<EOF
  cd /var/www/pweb/
  sudo git pull
  sudo restart uwsgi
  sudo restart nginx
  exit
EOF
