#!/bin/bash

URL="$(curl ifconfig.me)"
sed -i "s/{{URL}}/$URL/g" /home/ubuntu/food-ordering/food-ordering-app/frontend/.env
