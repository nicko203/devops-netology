## Домашнее задание к занятию "3.1. Работа в терминале, лекция 1"

### 1. Установка Oracle VirtualBox:

dpkg -i ./virtualbox-6.1_6.1.30-148432_Debian_buster_amd64.deb

### 2. Установка Hashicorp Vagrant:

curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
apt-get update && sudo apt-get install vagrant


