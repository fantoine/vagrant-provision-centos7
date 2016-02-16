#!/bin/bash

version="$1"
directory='/usr/share/phpmyadmin'

function phpmyadmin_sed {
    mode="$1"
    pattern=$( echo "$2" | sed -e 's/[]\/$*.^|[]/\\&/g' )
    content=$( echo "$3" | sed -e 's/[]\/$*.^|[]/\\&/g' )

    if [ "$mode" == 's' ]; then
        sed -i -e "s/$pattern.*/$content/" $directory/config.inc.php
    elif [ "$mode" == 'a' ]; then
        sed -i -e "/$pattern.*/a $content" $directory/config.inc.php
    elif [ "$mode" == 'i' ]; then
        sed -i -e "/$pattern.*/i $content" $directory/config.inc.php
    fi
}
function phpmyadmin_uncomment {
    content="$1"
    phpmyadmin_sed s "// $content" "$content"
}

if [ ! -d $directory ]; then
    echo 'Installing PhpMyAdmin'

    # Download latest phpMyAdmin
    mkdir -p /tmp/phpmyadmin
    wget -O /tmp/phpmyadmin/phpmyadmin.tar.gz "https://files.phpmyadmin.net/phpMyAdmin/${version}/phpMyAdmin-${version}-all-languages.tar.gz" >/dev/null 2>&1
    tar xvf /tmp/phpmyadmin/phpmyadmin.tar.gz -C /tmp/phpmyadmin >/dev/null 2>&1

    # Download theme
    wget -O /tmp/phpmyadmin/metro-theme.tar.gz https://files.phpmyadmin.net/themes/metro/2.2/metro-2.2.zip >/dev/null 2>&1
    unzip /tmp/phpmyadmin/metro-theme.tar.gz -d /tmp/phpmyadmin >/dev/null 2>&1

    # Copy installation to specific folder
    mkdir -p /usr/share
    mv "/tmp/phpmyadmin/phpMyAdmin-${version}-all-languages" $directory
    mv /tmp/phpmyadmin/metro $directory/themes/metro

    # Remove temporary directory
    rm -rf /tmp/phpmyadmin
fi

if [ ! -f /etc/httpd/conf.d/phpmyadmin.conf ]; then
    echo 'Configuring PhpMyAdmin'

    # Create phpMyAdmin configuration storage
    mysql -u root --password=vagrant < $directory/sql/create_tables.sql >/dev/null 2>&1

    # Update phpMyAdmin configuration
    cp $directory/config.sample.inc.php $directory/config.inc.php
    secret=$( echo -n "vagrant:secret:$( date )" | md5sum | awk '{print $1}' )
    phpmyadmin_sed s "\$cfg['blowfish_secret'] =" "\$cfg['blowfish_secret'] = '$secret';"
    phpmyadmin_sed s "\$cfg['Servers'][\$i]['auth_type']" "\$cfg['Servers'][\$i]['auth_type'] = 'config';"
    phpmyadmin_sed a "\$cfg['Servers'][\$i]['auth_type']" "\$cfg['Servers'][\$i]['user'] = 'root';"
    phpmyadmin_sed a "\$cfg['Servers'][\$i]['user']" "\$cfg['Servers'][\$i]['password'] = 'vagrant';"
    phpmyadmin_sed a "\$cfg['Servers'][\$i]['compress']" "\$cfg['Servers'][\$i]['extension'] = 'mysqli';"
    phpmyadmin_sed s "\$cfg['Servers'][\$i]['AllowNoPassword']" "\$cfg['Servers'][\$i]['AllowNoPassword'] = true;"
    phpmyadmin_sed a "\$cfg['Servers'][\$i]['AllowNoPassword']" "\$cfg['Servers'][\$i]['nopassword'] = true;"
    phpmyadmin_sed s "// \$cfg['Servers'][\$i]['controluser']" "\$cfg['Servers'][\$i]['controluser'] = 'root';"
    phpmyadmin_sed s "// \$cfg['Servers'][\$i]['controlpass']" "\$cfg['Servers'][\$i]['controlpass'] = 'vagrant';"
    phpmyadmin_sed a "\$cfg['SaveDir']" "\$cfg['ThemeManager'] = true;"
    phpmyadmin_sed a "\$cfg['ThemeManager']" "\$cfg['ThemeDefault'] = 'metro';"

    phpmyadmin_uncomment "\$cfg['Servers'][\$i]['pmadb'] = 'phpmyadmin';"
    phpmyadmin_uncomment "\$cfg['Servers'][\$i]['bookmarktable'] = 'pma__bookmark';"
    phpmyadmin_uncomment "\$cfg['Servers'][\$i]['relation'] = 'pma__relation';"
    phpmyadmin_uncomment "\$cfg['Servers'][\$i]['table_info'] = 'pma__table_info';"
    phpmyadmin_uncomment "\$cfg['Servers'][\$i]['table_coords'] = 'pma__table_coords';"
    phpmyadmin_uncomment "\$cfg['Servers'][\$i]['pdf_pages'] = 'pma__pdf_pages';"
    phpmyadmin_uncomment "\$cfg['Servers'][\$i]['column_info'] = 'pma__column_info';"
    phpmyadmin_uncomment "\$cfg['Servers'][\$i]['history'] = 'pma__history';"
    phpmyadmin_uncomment "\$cfg['Servers'][\$i]['table_uiprefs'] = 'pma__table_uiprefs';"
    phpmyadmin_uncomment "\$cfg['Servers'][\$i]['tracking'] = 'pma__tracking';"
    phpmyadmin_uncomment "\$cfg['Servers'][\$i]['userconfig'] = 'pma__userconfig';"
    phpmyadmin_uncomment "\$cfg['Servers'][\$i]['recent'] = 'pma__recent';"
    phpmyadmin_uncomment "\$cfg['Servers'][\$i]['favorite'] = 'pma__favorite';"
    phpmyadmin_uncomment "\$cfg['Servers'][\$i]['users'] = 'pma__users';"
    phpmyadmin_uncomment "\$cfg['Servers'][\$i]['usergroups'] = 'pma__usergroups';"
    phpmyadmin_uncomment "\$cfg['Servers'][\$i]['navigationhiding'] = 'pma__navigationhiding';"
    phpmyadmin_uncomment "\$cfg['Servers'][\$i]['savedsearches'] = 'pma__savedsearches';"
    phpmyadmin_uncomment "\$cfg['Servers'][\$i]['central_columns'] = 'pma__central_columns';"

    # Create Apache configuration
    mkdir -p /var/lib/phpmyadmin/tmp
    cp /vagrant/vagrant/data/tools/phpmyadmin.conf /etc/httpd/conf.d/phpmyadmin.conf

    # Restart Apache
    service httpd restart >/dev/null 2>&1
fi
