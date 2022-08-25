# Домашнее задание к занятию "09.03 Jenkins"

## Подготовка к выполнению

1. Установить jenkins по любой из [инструкций](https://www.jenkins.io/download/)
```
# ps aux | grep docker
root      407861  0.1  0.7 1680468 94988 ?       Ssl  09:21   0:00 /usr/bin/dockerd -H fd:// -H tcp://0.0.0.0:2376 -H unix:///var/run/docker.sock --containerd=/run/containerd/containerd.sock


# docker pull jenkins/jenkins
# docker run -d -p 8080:8080 -p 50000:50000 --name jenkins jenkins/jenkins
# docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
0088bdc1437546a597ae67534c69c747
```
2. Запустить и проверить работоспособность:  

![start_jenkins](start_jenkins.png)

3. Сделать первоначальную настройку
4. Настроить под свои нужды
5. Поднять отдельный cloud

`Dashboard -> Configure Cloud -> Add a new cloud (Docker)`
  
![jenkins_cloud_create](jenkins_cloud_create.png)


`Docker Agent templates -> Add docker template`
  
![jenkins_docker_agent](jenkins_docker_agent.png)


6. Для динамических агентов можно использовать [образ](https://hub.docker.com/repository/docker/aragast/agent)
7. Обязательный параметр: поставить label для динамических агентов: `ansible_docker`
8.  Сделать форк репозитория с [playbook](https://github.com/aragastmatb/example-playbook)

## Основная часть

1. Сделать Freestyle Job, который будет запускать `ansible-playbook` из форка репозитория
2. Сделать Declarative Pipeline, который будет выкачивать репозиторий с плейбукой и запускать её
3. Перенести Declarative Pipeline в репозиторий в файл `Jenkinsfile`
4. Перенастроить Job на использование `Jenkinsfile` из репозитория
5. Создать Scripted Pipeline, наполнить его скриптом из [pipeline](./pipeline)
6. Заменить credentialsId на свой собственный
7. Проверить работоспособность, исправить ошибки, исправленный Pipeline вложить в репозитрий в файл `ScriptedJenkinsfile`
8. Отправить ссылку на репозиторий в ответе

## Необязательная часть

1. Создать скрипт на groovy, который будет собирать все Job, которые завершились хотя бы раз неуспешно. Добавить скрипт в репозиторий с решеним с названием `AllJobFailure.groovy`
2. Установить customtools plugin
3. Поднять инстанс с локальным nexus, выложить туда в анонимный доступ  .tar.gz с `ansible`  версии 2.9.x
4. Создать джобу, которая будет использовать `ansible` из `customtool`
5. Джоба должна просто исполнять команду `ansible --version`, в ответ прислать лог исполнения джобы 

---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
