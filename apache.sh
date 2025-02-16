#!/bin/bash

# Mettre à jour les paquets
apt update && apt upgrade -y

# Installer Apache2 et les modules nécessaires
apt install apache2 openssl -y

# Activer les modules nécessaires
a2enmod ssl
a2enmod rewrite

# Créer un répertoire pour le site
mkdir -p /var/www/html/localhost1234
mkdir -p /var/www/html/localhost9000

# Créer une page d'accueil simple pour chaque site
echo "<h1>Bienvenue sur localhost:1234</h1>" > /var/www/html/localhost1234/index.html
echo "<h1>Bienvenue sur localhost:9000</h1>" > /var/www/html/localhost9000/index.html

# Créer un fichier de configuration pour localhost:1234
cat <<EOL > /etc/apache2/sites-available/localhost1234.conf
<VirtualHost *:1234>
    DocumentRoot /var/www/html/localhost1234
    ServerName localhost

    <Directory /var/www/html/localhost1234>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/localhost1234_error.log
    CustomLog \${APACHE_LOG_DIR}/localhost1234_access.log combined
</VirtualHost>
EOL

# Créer un fichier de configuration pour localhost:443 avec HTTPS
cat <<EOL > /etc/apache2/sites-available/localhost9000.conf
<VirtualHost *:443>
    DocumentRoot /var/www/html/localhost9000
    ServerName localhost

    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/selfsigned.crt
    SSLCertificateKeyFile /etc/ssl/private/selfsigned.key

    <Directory /var/www/html/localhost9000>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/localhost9000_error.log
    CustomLog \${APACHE_LOG_DIR}/localhost9000_access.log combined
</VirtualHost>
EOL

# Générer un certificat SSL auto-signé
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/selfsigned.key -out /etc/ssl/certs/selfsigned.crt -subj "/C=FR/ST=France/L=Paris/O=MonOrganisation/OU=MonUnite/CN=localhost"

# Activer les sites
a2ensite localhost1234.conf
a2ensite localhost9000.conf

# Vérifier la configuration d'Apache avant de redémarrer
apachectl configtest

# Redémarrer Apache2 pour appliquer les changements
systemctl restart apache2

# Assurez-vous que le service Apache fonctionne
if systemctl status apache2 | grep "active (running)"; then
    echo "Apache2 a été installé et configuré avec succès."
    echo "Vous pouvez accéder à votre site sur http://localhost:1234 et https://localhost:443."
else
    echo "Échec du démarrage d'Apache2. Vérifiez les logs pour plus de détails."
fi




