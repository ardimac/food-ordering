#!/bin/bash
set -e

## NODE & NPM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
nvm install node

NPM="$(which npm)"
ln -s $NPM /usr/bin/npm

NODE="$(which node)"
ln -s $NODE /usr/bin/node

## CLONE REPO
git clone https://github.com/ardimac/food-ordering.git

## frontend
cd food-ordering/food-ordering-app/frontend/
npm install
URL="$(curl ifconfig.me)"
sed -i "s/{{URL}}/$URL/g" /home/ubuntu/food-ordering/food-ordering-app/frontend/.env

## backend
cd food-ordering/food-ordering-app/backend/
npm init -y
npm install express pg cors body-parser

## config
sudo cp /home/ubuntu/food-ordering/config/systemd/*-app.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable frontend-app.service
sudo systemctl enable backend-app.service
sudo systemctl start frontend-app.service
sudo systemctl start backend-app.service

sudo apt install -y nginx
sudo unlink /etc/nginx/sites-enabled/default
sudo cp /home/ubuntu/food-ordering/config/nginx/food-ordering /etc/nginx/sites-available
sudo ln -s /etc/nginx/sites-available/food-ordering /etc/nginx/sites-enabled/
sudo systemctl start nginx
sudo systemctl enable nginx
