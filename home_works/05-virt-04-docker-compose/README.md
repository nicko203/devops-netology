## Домашнее задание к занятию "5.4. Оркестрация группой Docker контейнеров на примере Docker Compose"  

### Задача 1.  
Создать собственный образ операционной системы с помощью Packer.  
Для получения зачета, вам необходимо предоставить: cкриншот страницы, как на слайде из презентации (слайд 37).  

### Ответ:  

Скриншот консоли Yandex.Cloud:  

![packer_centos7_screenshot.png](packer_centos7_screenshot.png)  

Процесс выполнения команды сборки образа  :  
```bash
$ packer build centos-7-base.json
```

![packer_centos7.png](packer_centos7.png)  


### Задача 2.  
Создать вашу первую виртуальную машину в Яндекс.Облаке.  

### Ответ:  

Скриншот консоли Yandex.Cloud:  

![terraform_apply_screenshot.png](terraform_apply_screenshot.png)  

Процесс выполнения команды запуска ВМ :  
```bash
$ terraform init
$ terraform validate
$ terraform plan
$ terraform apply -auto-approve
```
  
![terraform_apply.png](terraform_apply.png)  



### Задача 3.  
Создать ваш первый готовый к боевой эксплуатации компонент мониторинга, состоящий из стека микросервисов.  
Для получения зачета, вам необходимо предоставить: скриншот работающего веб-интерфейса Grafana с текущими метриками.  

### Ответ:  

![grafana_1.png](grafana_1.png)  

