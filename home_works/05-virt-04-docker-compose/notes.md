### Порядок выполнения работы.

1. Собираем собственный образ на Yandex.Cloud  

Для этого используем инструкцию https://sysad.su/создание-собственного-образа-в-yandex-cloud/  
Шаблоном для сборки служит файл  centos-7-base.json из каталога ./src/packer  
В шаблоне изменяем параметры folder-id, token, subnet_id.

Сборка образа производится командами:  
```bash
# packer init
# packer validate centos-7-base.json
# packer build centos-7-base.json
```
Проверяем наличие образов:  
```bash
yc compute image list
```

2. Создание виртуальной машины с помощью terraform  

Создаю ключ для сервисного аккаунта nicko2022:  
```bash
# yc iam key create --service-account-name nicko2022 -o ./nicko2022.json
```
  
В каталоге /src/terraform вносим изменения в файл variables.tf, а именно меняем значения переменных yandex_cloud_id, yandex_folder_id, centos-7-base на свои и в файл provider.tf - в качестве значения переменной service_account_key_file указываю _*nicko2022.json*_.  

Создаю ВМ:  
```bash
# terraform init
# terraform validate
#$ terraform plan
#$ terraform apply -auto-approve
```

Проверяю:  
```bash
# yc compute instance list
```
  
Подключение по SSH:  
```bash
# ssh centos@IP
```

3. Запускаю сервисы на ВМ:  
В каталоге ./src/ansible в файле inventory меняю значение переменной node01.netology.cloud ansible_host  на внешний IP-адрес ВМ.  

Выполняю playbook:  
```bash
ansible-playbook provision.yml
```

Веб-интерфейс grafana доступен по IP:3000 , admin/admin  