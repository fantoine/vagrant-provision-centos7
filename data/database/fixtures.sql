# Create project database
CREATE DATABASE IF NOT EXISTS `vagrant` /*!40100 DEFAULT CHARACTER SET utf8 */;
USE `vagrant`;

# Create user
CREATE USER 'vagrant'@'localhost' IDENTIFIED BY 'vagrant';
GRANT ALL PRIVILEGES ON vagrant.* to vagrant@localhost;
