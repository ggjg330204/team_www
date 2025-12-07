#!/bin/bash
set -e

exec > >(tee /var/log/mail-setup.log) 2>&1

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

error_handler() {
    log "ERROR: Command '$2' failed on line $1"
    exit 1
}

trap 'error_handler $LINENO "$BASH_COMMAND"' ERR

DOMAIN="04www.cloud"
HOSTNAME="mail.04www.cloud"

log "Starting Mail Server Setup"

export DEBIAN_FRONTEND=noninteractive

retry_cmd() {
    local n=1
    local max=3
    local delay=5
    while true; do
        "$@" && break || {
            if [[ $n -lt $max ]]; then
                ((n++))
                log "Command failed. Attempt $n/$max:"
                sleep $delay;
            else
                log "The command has failed after $n attempts."
                return 1
            fi
        }
    done
}

retry_cmd apt-get update
log "Upgrading packages..."
retry_cmd apt-get upgrade -y

debconf-set-selections <<< "postfix postfix/mailname string $HOSTNAME"
debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"

log "Installing packages..."
retry_cmd apt-get install -y postfix postfix-policyd-spf-python
retry_cmd apt-get install -y dovecot-core dovecot-imapd dovecot-pop3d dovecot-lmtpd dovecot-mysql
retry_cmd apt-get install -y default-mysql-client

postconf -e "myhostname = $HOSTNAME"
postconf -e "mydomain = $DOMAIN"
postconf -e "myorigin = \$mydomain"
postconf -e "mydestination = \$myhostname, localhost.\$mydomain, localhost, \$mydomain"
postconf -e "inet_interfaces = all"
postconf -e "inet_protocols = ipv4"
postconf -e "home_mailbox = Maildir/"
postconf -e "mailbox_transport = lmtp:unix:private/dovecot-lmtp"
postconf -e "smtpd_banner = \$myhostname ESMTP"
postconf -e "smtpd_helo_required = yes"
postconf -e "smtpd_helo_restrictions = permit_mynetworks, reject_invalid_helo_hostname"
postconf -e "smtpd_sender_restrictions = permit_mynetworks, reject_unknown_sender_domain"
postconf -e "smtpd_recipient_restrictions = permit_sasl_authenticated, permit_mynetworks, reject_unauth_destination"
postconf -e "smtpd_sasl_auth_enable = yes"
postconf -e "smtpd_sasl_type = dovecot"
postconf -e "smtpd_sasl_path = private/auth"
postconf -e "smtpd_sasl_security_options = noanonymous"
postconf -e "smtpd_sasl_local_domain = \$myhostname"
postconf -e "broken_sasl_auth_clients = yes"
postconf -e "message_size_limit = 52428800"
postconf -e "mailbox_size_limit = 1073741824"

cat > /etc/dovecot/conf.d/10-mail.conf << 'EOF'
mail_location = maildir:~/Maildir
namespace inbox {
  inbox = yes
}
mail_privileged_group = mail
first_valid_uid = 5000
last_valid_uid = 5000
EOF

cat > /etc/dovecot/conf.d/10-auth.conf << 'EOF'
disable_plaintext_auth = no
auth_mechanisms = plain login
!include auth-sql.conf.ext
EOF

cat > /etc/dovecot/dovecot-sql.conf.ext << 'EOF'
driver = mysql
connect = host=${db_host} dbname=${db_name} user=${db_user} password=${db_password}
default_pass_scheme = BLF-CRYPT
password_query = SELECT username as user, password FROM users WHERE username='%u' OR username=CONCAT('%n', '@04www.cloud');
user_query = SELECT username as user, 5000 as uid, 5000 as gid, '/home/vmail/%n' as home FROM users WHERE username='%u' OR username=CONCAT('%n', '@04www.cloud');
EOF

cat > /etc/dovecot/conf.d/10-auth.conf << 'EOF'
disable_plaintext_auth = no
auth_mechanisms = plain login
!include auth-sql.conf.ext
EOF

cat > /etc/dovecot/conf.d/auth-sql.conf.ext <<'EOF'
passdb {
  driver = sql
  args = /etc/dovecot/dovecot-sql.conf.ext
}
userdb {
  driver = sql
  args = /etc/dovecot/dovecot-sql.conf.ext
}
EOF

cat > /etc/dovecot/conf.d/10-master.conf << 'EOF'
service imap-login {
  inet_listener imap {
    port = 143
  }
}
service pop3-login {
  inet_listener pop3 {
    port = 110
  }
}
service lmtp {
  unix_listener /var/spool/postfix/private/dovecot-lmtp {
    mode = 0600
    user = postfix
    group = postfix
  }
}
service auth {
  unix_listener /var/spool/postfix/private/auth {
    mode = 0660
    user = postfix
    group = postfix
  }
  unix_listener auth-userdb {
    mode = 0600
    user = mail
  }
  user = dovecot
}
service auth-worker {
  user = root
}
EOF

log "Installing Webmail packages..."
retry_cmd apt-get install -y apache2 php libapache2-mod-php php-xml php-mbstring php-intl php-zip php-pear php-net-smtp php-mysql php-gd php-curl
retry_cmd apt-get install -y php-sqlite3 sqlite3
retry_cmd apt-get install -y roundcube roundcube-core roundcube-plugins

cat > /etc/apache2/sites-available/mail.conf << 'EOF'
<VirtualHost *:80>
    ServerName mail.04www.cloud
    ServerAlias *
    ServerAdmin admin@04www.cloud
    DocumentRoot /var/lib/roundcube/public_html

    <Directory /var/lib/roundcube/public_html>
        Options +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    <Directory /var/lib/roundcube/config>
        Options -FollowSymLinks
        AllowOverride None
        Require all denied
    </Directory>

    ErrorLog $${APACHE_LOG_DIR}/mail_error.log
    CustomLog $${APACHE_LOG_DIR}/mail_access.log combined
</VirtualHost>
EOF

if [ -f /etc/apache2/sites-enabled/000-default.conf ]; then
    a2dissite 000-default.conf || true
    rm -f /etc/apache2/sites-enabled/000-default.conf
fi

if [ ! -f /etc/apache2/sites-enabled/mail.conf ]; then
    a2ensite mail.conf || true
fi

a2enmod rewrite 2>/dev/null || true

cat > /etc/roundcube/config.inc.php << 'EOF'
<?php
$config = [];
$config['db_dsnw'] = 'sqlite:////var/lib/roundcube/db/sqlite.db';
$config['imap_host'] = '127.0.0.1:143';
$config['smtp_host'] = '127.0.0.1:25';
$config['smtp_user'] = '%u';
$config['smtp_pass'] = '%p';
$config['product_name'] = '04www Cloud Mail';
$config['support_url'] = '';
$config['des_key'] = 'Ml9xPc2kSwR2vU8Tq5nFjAi4';
$config['skin'] = 'elastic';
$config['skin_logo'] = null;
$config['language'] = 'ko_KR';
$config['timezone'] = 'Asia/Seoul';
$config['username_domain'] = '04www.cloud';
$config['mail_domain'] = '04www.cloud';
$config['default_host'] = 'localhost';
$config['default_port'] = 143;
$config['auto_create_user'] = true;
$config['mail_pagesize'] = 50;
$config['list_cols'] = ['threads', 'subject', 'from', 'date', 'size', 'flag', 'attachment'];
$config['message_show_email'] = true;
$config['preview_pane'] = true;
$config['prefer_html'] = true;
$config['htmleditor'] = 4;
$config['draft_autosave'] = 60;
$config['show_images'] = 1;
$config['plugins'] = ['archive', 'zipdownload', 'emoticons', 'markasjunk', 'newmail_notifier'];
$config['login_rate_limit'] = 5;
$config['session_lifetime'] = 60;
$config['ip_check'] = false;
$config['max_message_size'] = '50M';
$config['upload_max_filesize'] = '50M';
EOF

mkdir -p /var/lib/roundcube/db
if [ ! -s /var/lib/roundcube/db/sqlite.db ]; then
    cat /usr/share/dbconfig-common/data/roundcube/install/sqlite3 | sqlite3 /var/lib/roundcube/db/sqlite.db 2>/dev/null || true
fi
chown -R www-data:www-data /var/lib/roundcube/db
chmod 755 /var/lib/roundcube/db
chmod 644 /var/lib/roundcube/db/sqlite.db

getent group vmail >/dev/null || groupadd -g 5000 vmail
id -u vmail >/dev/null 2>&1 || useradd -g vmail -u 5000 vmail -d /home/vmail
mkdir -p /home/vmail
chown vmail:vmail /home/vmail

for user in admin www user1 user2 support; do
    if ! id "$user" &>/dev/null; then
        if getent group "$user" >/dev/null; then
            useradd -m -s /bin/bash -g "$user" "$user"
        else
            useradd -m -s /bin/bash "$user"
        fi
    fi
    echo "$user:It12345!" | chpasswd
    
    mkdir -p /home/$user/Maildir/{new,cur,tmp}
    chown -R $user:$user /home/$user/Maildir
    chmod -R 700 /home/$user/Maildir
done

echo "mail.* /var/log/mail.log" > /etc/rsyslog.d/50-mail.conf
systemctl restart rsyslog || true

echo "www ALL=(ALL) NOPASSWD: /usr/sbin/useradd, /usr/sbin/chpasswd, /bin/mkdir, /bin/chown, /bin/chmod" > /etc/sudoers.d/www-mail
chmod 440 /etc/sudoers.d/www-mail

mkdir -p /var/lib/roundcube/skins/elastic/styles
cat > /var/lib/roundcube/skins/elastic/styles/dark-custom.css << 'CSS'
:root {
    --main-bg: #0a0a0a !important;
    --layout-header-bg: #121212 !important;
    --layout-sidebar-bg: #0f0f0f !important;
    --layout-content-bg: #0a0a0a !important;
    --list-bg: #121212 !important;
    --list-selected-bg: #1a1a2e !important;
    --list-hover-bg: #1e1e1e !important;
    --primary-color: #667eea !important;
    --link-color: #8b9cf4 !important;
    --border-color: #2a2a2a !important;
}

body {
    background: linear-gradient(135deg, #0a0a0a 0%, #1a1a2e 100%) !important;
}

.menu a, .toolbar a {
    color: #a0a0a0 !important;
}

.menu a:hover, .toolbar a:hover {
    color: #667eea !important;
    background: rgba(102, 126, 234, 0.1) !important;
}

#layout-sidebar {
    background: linear-gradient(180deg, #0f0f0f 0%, #1a1a1a 100%) !important;
    border-right: 1px solid #2a2a2a !important;
}

#layout-content {
    background: #0a0a0a !important;
}

.listing tbody tr:hover td {
    background: rgba(102, 126, 234, 0.15) !important;
}

.listing tbody tr.selected td {
    background: rgba(102, 126, 234, 0.25) !important;
}

.button.mainaction {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%) !important;
    border: none !important;
    box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3) !important;
}

.button.mainaction:hover {
    box-shadow: 0 6px 20px rgba(102, 126, 234, 0.5) !important;
    transform: translateY(-1px);
}

#layout-menu .special-buttons {
    background: transparent !important;
}

.message-partheaders {
    background: #1e1e1e !important;
    border-bottom: 1px solid #333 !important;
}

::-webkit-scrollbar {
    width: 8px;
    background: #0a0a0a;
}

::-webkit-scrollbar-thumb {
    background: #333;
    border-radius: 4px;
}

::-webkit-scrollbar-thumb:hover {
    background: #444;
}
CSS

chgrp shadow /etc/shadow 2>/dev/null || true
chmod g+r /etc/shadow 2>/dev/null || true
usermod -aG shadow dovecot 2>/dev/null || true

log "Restarting services"
systemctl restart postfix
systemctl restart dovecot
systemctl restart apache2
systemctl enable postfix dovecot apache2

ufw allow 25/tcp 2>/dev/null || true
ufw allow 110/tcp 2>/dev/null || true
ufw allow 143/tcp 2>/dev/null || true
ufw allow 80/tcp 2>/dev/null || true

# Vulnerable Account for Brute Force Training
useradd -m -s /bin/bash guest || true
echo "guest:guest" | chpasswd
mkdir -p /home/guest/Maildir/{new,cur,tmp}
chown -R guest:guest /home/guest/Maildir
chmod -R 700 /home/guest/Maildir

# Fail2Ban Installation (DISABLED for Brute Force Training)
# To enable protection: systemctl start fail2ban
retry_cmd apt-get install -y fail2ban

cat > /etc/fail2ban/jail.local << 'EOF'
[DEFAULT]
bantime  = 1h
findtime = 10m
maxretry = 5
ignoreip = 127.0.0.1/8 ::1

[sshd]
enabled = true
port    = ssh
logpath = %(sshd_log)s
backend = %(sshd_backend)s

[postfix-sasl]
enabled = true
port    = smtp,587,submission
filter  = postfix[mode=auth]
logpath = /var/log/mail.log

[dovecot]
enabled = true
port    = pop3,pop3s,imap,imaps,submission,4190
filter  = dovecot
logpath = /var/log/mail.log
EOF

# Explicitly disable fail2ban for training scenarios
systemctl stop fail2ban
systemctl disable fail2ban

log "Mail Server Setup Complete"
echo ""
echo "========================================="
echo "  04www Cloud Mail Server"
echo "========================================="
echo "Webmail URL   : http://mail.04www.cloud/"
echo ""
echo "Accounts (Password: It12345!):"
echo "  - admin@04www.cloud"
echo "  - www@04www.cloud"
echo "  - user1@04www.cloud"
echo "  - user2@04www.cloud"  
echo "  - support@04www.cloud"
echo "  - guest@04www.cloud"
echo ""
echo "Theme: Dark Mode (Elastic)"
echo "========================================="
