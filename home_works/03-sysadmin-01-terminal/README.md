## Домашнее задание к занятию "3.1. Работа в терминале, лекция 1"

### 1. Установка Oracle VirtualBox:

**Oracle VirtualBox** установлен на рабочей станции под управлением Windows 7 x64.

### 2. Установка Hashicorp Vagrant:

**Hashicorp** Vagrant установлен на рабочей станции под управлением Windows 7 x64.

### 3. -

### 4. С помощью базового файла конфигурации запустите Ubuntu 20.04 в VirtualBox посредством Vagrant.

- создан каталог для хранения виртуальной машины;
- выполнена инициализация: *vagrant init* ;
- скорректирован файл конфигурации;
- виртуальная машина запушена: *vagrant up* :

### 5. Графический интерфейс VirtualBox

![VirtualBox](virtualbox_ubuntu20.jpg)

По умолчанию выделенно: 1 ГБ ОЗУ, 2 ядра CPU.

###6. Добавление ресурсов

Для добавления ресурсов ВМ корректируем файл Vagrantfile, увеличиваем размер ОЗУ до 2 ГБ:

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-20.04"
  
  config.vm.provider "virtualbox" do |v|
    v.memory = 2048
    v.cpus = 2
  end
end

Для вступления изменений в силу перечитываем конфигурацию: *vagrant reload*

###7. Доступ к консоли виртуальной машины: vagrant ssh

![VagrantUP](vargant_up.jpg)


###8. Знакомство с man bash
