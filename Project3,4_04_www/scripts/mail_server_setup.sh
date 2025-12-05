#!/bin/bash
DOMAIN="04www.cloud"
HOSTNAME="mail.04www.cloud"

sudo apt-get update
sudo debconf-set-selections <<< "postfix postfix/mailname string $HOSTNAME"
sudo debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"
sudo apt-get install -y postfix dovecot-core dovecot-imapd

sudo postconf -e "myhostname = $HOSTNAME"
sudo postconf -e "mydomain = $DOMAIN"
sudo postconf -e "myorigin = \$mydomain"
sudo postconf -e "mydestination = \$myhostname, localhost.\$mydomain, localhost, \$mydomain"
sudo postconf -e "inet_interfaces = all"
sudo postconf -e "smtpd_sasl_auth_enable = yes"
sudo postconf -e "smtpd_sasl_type = dovecot"
sudo postconf -e "smtpd_sasl_path = private/auth"
sudo postconf -e "smtpd_recipient_restrictions = permit_sasl_authenticated, permit_mynetworks, reject_unauth_destination"

sudo tee /etc/dovecot/conf.d/99-auth-postfix.conf > /dev/null <<EOF
service auth {
  unix_listener /var/spool/postfix/private/auth {
    mode = 0660
    user = postfix
    group = postfix
  }
}
EOF

sudo sed -i 's/#disable_plaintext_auth = yes/disable_plaintext_auth = no/' /etc/dovecot/conf.d/10-auth.conf
sudo sed -i 's/auth_mechanisms = plain/auth_mechanisms = plain login/' /etc/dovecot/conf.d/10-auth.conf

sudo DEBIAN_FRONTEND=noninteractive apt-get install -y apache2 php libapache2-mod-php php-xml php-mbstring php-intl php-zip php-pear php-net-smtp php-mail-mime
sudo apt-get install -y roundcube roundcube-core roundcube-plugins

sudo tee /etc/apache2/conf-available/roundcube.conf > /dev/null <<EOF
Alias /roundcube /var/lib/roundcube/public_html
Alias /mail /var/lib/roundcube/public_html
<Directory /var/lib/roundcube/public_html>
  Options +FollowSymLinks
  AllowOverride All
  Require all granted
</Directory>
EOF

sudo a2enconf roundcube
sudo a2enmod rewrite

sudo sed -i "s/\\\$config\['default_host'\] = .*/\\\$config['default_host'] = 'localhost';/" /etc/roundcube/config.inc.php
sudo sed -i "s/\\\$config\['smtp_server'\] = .*/\\\$config['smtp_server'] = 'localhost';/" /etc/roundcube/config.inc.php
sudo sed -i "s/\\\$config\['smtp_port'\] = .*/\\\$config['smtp_port'] = 25;/" /etc/roundcube/config.inc.php

id www &>/dev/null || sudo useradd -m -s /bin/bash www
echo "www:It12345!" | sudo chpasswd
sudo mkdir -p /home/www/Maildir
sudo chown -R www:www /home/www/Maildir

echo "mail.* /var/log/mail.log" | sudo tee -a /etc/rsyslog.d/50-mail.conf
sudo systemctl restart rsyslog

sudo systemctl restart postfix dovecot apache2
sudo systemctl enable postfix dovecot apache2

echo "=== Mail Server Setup Complete ==="
echo "Webmail: http://mail.04www.cloud/roundcube"
echo "Account: www / It12345!"
