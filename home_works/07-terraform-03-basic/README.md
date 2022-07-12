# Домашнее задание к занятию "7.3. Основы и принцип работы Терраформ"

## Задача 1. Создадим бэкэнд в S3 (необязательно, но крайне желательно).

Если в рамках предыдущего задания у вас уже есть аккаунт AWS, то давайте продолжим знакомство со взаимодействием
терраформа и aws. 

1. Создайте s3 бакет, iam роль и пользователя от которого будет работать терраформ. Можно создать отдельного пользователя,
а можно использовать созданного в рамках предыдущего задания, просто добавьте ему необходимы права, как описано 
[здесь](https://www.terraform.io/docs/backends/types/s3.html).
1. Зарегистрируйте бэкэнд в терраформ проекте как описано по ссылке выше. 

## Решение.  

Выполняю в Yandex Cloud.  

Определяю файлы Terraform для создания S3 бакета:  

- variables.tf  
```bash
variable "yandex_cloud_id" {
  default = "b1gusbu5rl5peuirh6d4"
}

variable "yandex_folder_id" {
  default = "b1giv01e8j41n6fkprqq"
}

```

- provider.tf  
```bash
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  #  token     = "<OAuth>"  Load from environment var YC_TOKEN

# Load from variables.tf
  cloud_id  = "${var.yandex_cloud_id}"
  folder_id = "${var.yandex_folder_id}"

  zone      = "ru-central1-a"
}
```

- outputs.tf  
Делается для получения значений аргументов access_key и secret_key и сохранения данных значений в файле состояния. Если access_key можно посмотреть в панели Яндекса, то secret_key мы увидеть не можем.
```bash
output "access_key" {
  value = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  sensitive = true
}
output "secret_key" {
  value = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  sensitive = true
}
```

- s3.tf  
Создаю сервисный аккаунт с ролью storage.editor, получаю ключи для сервисного аккаунта, создаю бакет.  
```bash
resource "yandex_iam_service_account" "s3" {
  folder_id = "${var.yandex_folder_id}"
  name      = "s3-nicko2003"
}

resource "yandex_resourcemanager_folder_iam_member" "sa-editor" {
  folder_id = "${var.yandex_folder_id}"
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.s3.id}"
}

resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.s3.id
  description        = "Static access key for object storage"
}

resource "yandex_storage_bucket" "state-nicko2003" {
  bucket     = "tf-state-bucket-test-nicko2003"
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
}
```

Регистрирую бэкэнд в терраформ проекте, для этого корректирую файл provider.tf, добавляю секцию backend "s3":  
```bash
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"


  backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "tf-state-bucket-test-nicko2003"
    region     = "ru-central1-a"
    key        = "terraform/infrastructure1/terraform.tfstate"

#Load from keys.tf
    access_key = "${var.yandex_cloud_s3_access_key}"
    secret_key = "${var.yandex_cloud_s3_secret_key}"

 
    skip_region_validation      = true
    skip_credentials_validation = true
  }

}

provider "yandex" {
  #  token     = "<OAuth>"  Load from environment var YC_TOKEN

# Load from variables.tf
  cloud_id  = "${var.yandex_cloud_id}"
  folder_id = "${var.yandex_folder_id}"

  zone      = "ru-central1-a"
}

```

## Задача 2. Инициализируем проект и создаем воркспейсы. 

1. Выполните `terraform init`:
    * если был создан бэкэнд в S3, то терраформ создат файл стейтов в S3 и запись в таблице 
dynamodb.
    * иначе будет создан локальный файл со стейтами.  
1. Создайте два воркспейса `stage` и `prod`.
1. В уже созданный `aws_instance` добавьте зависимость типа инстанса от вокспейса, что бы в разных ворскспейсах 
использовались разные `instance_type`.
1. Добавим `count`. Для `stage` должен создаться один экземпляр `ec2`, а для `prod` два. 
1. Создайте рядом еще один `aws_instance`, но теперь определите их количество при помощи `for_each`, а не `count`.
1. Что бы при изменении типа инстанса не возникло ситуации, когда не будет ни одного инстанса добавьте параметр
жизненного цикла `create_before_destroy = true` в один из рессурсов `aws_instance`.
1. При желании поэкспериментируйте с другими параметрами и рессурсами.

В виде результата работы пришлите:
* Вывод команды `terraform workspace list`.
* Вывод команды `terraform plan` для воркспейса `prod`.  

---

### Как cдавать задание

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
