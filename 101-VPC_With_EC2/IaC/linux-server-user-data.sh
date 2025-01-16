#!/bin/bash
yum install httpd -y
systemctl start httpd
systemctl enable httpd
echo "Hello from user data" > /var/www/html/index.html


