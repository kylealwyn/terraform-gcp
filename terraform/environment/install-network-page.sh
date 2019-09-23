sudo apt-get update
sudo apt-get install apache2 -y
sudo a2ensite default-ssl
sudo a2enmod ssl
sudo service apache2 restart
sudo cat > /var/www/html/index.html << EOF
<!doctype html><html><body>
<h1>hi!</h1>
</body></html>
EOF
