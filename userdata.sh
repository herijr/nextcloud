#!/bin/bash
sudo apt update
sudo apt -y upgrade
sudo apt install -y apache2
sudo apt install -y unzip bzip2 curl php php-mysql php-intl php-imagick php-bcmath php-zip php-dom php-mbstring php-xml php-gd php-curl nfs-common

sudo su

mkdir -p /var/www/html/nextcloud/apps
mkdir /var/www/html/nextcloud/config
mkdir /var/www/html/nextcloud/data
rm /var/www/html/index.html

sudo service apache2 restart

echo "apache reiniciado"

sudo apt-get -y install git binutils
git clone https://github.com/aws/efs-utils
cd efs-utils
./build-deb.sh
sudo apt-get -y install ./build/amazon-efs-utils*deb

sudo echo "${efs-id}:/ /var/www/html/nextcloud/apps efs _netdev,noresvport,tls,accesspoint=${apps} 0 0" >> /etc/fstab
sudo echo "${efs-id}:/ /var/www/html/nextcloud/config efs _netdev,noresvport,tls,accesspoint=${config} 0 0" >> /etc/fstab
sudo echo "${efs-id}:/ /var/www/html/nextcloud/data efs _netdev,noresvport,tls,accesspoint=${data} 0 0" >> /etc/fstab
sudo mount -a

echo "efs montado"

wget https://download.nextcloud.com/server/releases/latest.tar.bz2
sudo tar -jxvf latest.tar.bz2 -C /var/www/html
chown -R www-data:www-data /var/www/html
echo "copia finalizada"