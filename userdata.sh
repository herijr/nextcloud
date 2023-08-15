#!/bin/bash
sudo apt update
sudo apt -y upgrade
sudo apt install -y apache2
sudo apt install -y unzip bzip2 curl php php-mysql php-intl php-imagick php-bcmath php-zip php-dom php-mbstring php-xml php-gd php-curl nfs-common

sudo su

mkdir -p /var/www/nextcloud/apps
mkdir /var/www/nextcloud/config
mkdir /var/www/nextcloud/data

wget https://raw.githubusercontent.com/herijr/nextcloud/main/conf/site.conf

mv site.conf /etc/apache2/sites-available
a2ensite site.conf
a2dissite 000-default.conf
a2enmod rewrite
sudo sed -i '/^memory_limit =/s/=.*/= 512M/' /etc/php/8.1/apache2/php.ini
sudo service apache2 restart

echo "apache reiniciado"

sleep 5m

sudo apt-get -y install git binutils
git clone https://github.com/aws/efs-utils
cd efs-utils
./build-deb.sh
sudo apt-get -y install ./build/amazon-efs-utils*deb

sudo echo "${efs-id}:/ /var/www/nextcloud/apps efs _netdev,noresvport,tls,accesspoint=${apps} 0 0" >> /etc/fstab
sudo echo "${efs-id}:/ /var/www/nextcloud/config efs _netdev,noresvport,tls,accesspoint=${config} 0 0" >> /etc/fstab
sudo echo "${efs-id}:/ /var/www/nextcloud/data efs _netdev,noresvport,tls,accesspoint=${data} 0 0" >> /etc/fstab
sudo mount -a

echo "efs montado"

wget https://download.nextcloud.com/server/releases/latest.tar.bz2
sudo tar -jxvf latest.tar.bz2 -C /var/www
chown -R www-data:www-data /var/www/nextcloud
echo "copia finalizada"