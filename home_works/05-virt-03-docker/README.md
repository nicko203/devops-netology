## Домашнее задание к занятию "5.3. Введение. Экосистема. Архитектура. Жизненный цикл Docker контейнера"  

### Задача 1  

Сценарий выполения задачи:  

- создайте свой репозиторий на https://hub.docker.com;  
- выберете любой образ, который содержит веб-сервер Nginx;  
- создайте свой fork образа;  
- реализуйте функциональность: запуск веб-сервера в фоне с индекс-страницей, содержащей HTML-код ниже:  
```
<html>
<head>
Hey, Netology
</head>
<body>
<h1>I’m DevOps Engineer!</h1>
</body>
</html>
```
Опубликуйте созданный форк в своем репозитории и предоставьте ответ в виде ссылки на https://hub.docker.com/username_repo.  

### Ответ:  
https://hub.docker.com/repository/docker/nicko2003/devops-netology  

### Решение.  
На сервер с Debian 11 устанавливаю Docker:  

- Обновление пакетов:  
```bash
# apt-get update & apt-get upgrade
```  

- Установка пакетов, позволяющих работать apt через HTTPS:  
```bash
# apt-get install apt-transport-https ca-certificates curl gnupg2 software-properties-common
```

- Добавление GPG ключа:  
```bash
# curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
```

- Подключение стабильного (stable) репозитория docker:  
```bash
# add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
```

- Установка Docker:  
```bash
# apt-get update
# apt-get install docker-ce docker-ce-cli containerd.io
```  

- Получаю официальный образ nginx:  
```bash
# docker pull nginx
```
- Создаю рабочий каталог:  
```bash
# mkdir -p ~/netology/nicko-nginx-docker
```

- Создаю индексный файл _*index.html*_:  
```bash
# touch ~/netology/nicko-nginx-docker/index.html
```

- Создаю Dockerfile:  
```bash
# touch ~/netology/nicko-nginx-docker/Dockerfile
```
- В Dockerfile вставляю следующие команды:  
Первой командой *_FROM_*  создаю собственный образ, используя базовый образ.  Это вытянет nginx-образ на локальную машину, а затем создаст собственный образ поверх него.  
Команда COPY помешает файл index.html в /usr/share/nginx/html каталог внутри контейнера и перезаписывает файл по умолчанию index.html , предоставленный nginx-образом.  
```
FROM nginx
COPY ./index.html /usr/share/nginx/html/index.html
```

- Собираю собственный образ:  
```bash
# docker build -t nicko-nginx-docker .
```
Вывод команды:  
```
Sending build context to Docker daemon  3.072kB
Step 1/2 : FROM nginx:latest
 ---> de2543b9436b
Step 2/2 : COPY ./index.html /usr/share/nginx/html/index.html
 ---> a70f2e4ed111
Successfully built a70f2e4ed111
Successfully tagged nicko-nginx-docker:latest
```
Образ собран:  
```bash
# docker images
REPOSITORY           TAG       IMAGE ID       CREATED              SIZE
nicko-nginx-docker   latest    39524532c421   3 minutes ago        142MB
nginx                latest    de2543b9436b   29 hours ago         142MB
hello-world          latest    feb5d9fea6a5   7 months ago         13.3kB
```

- Стартую контейнер:  
```bash
# docker run -d -p 8888:80 --name web nicko-nginx-docker
741dbeb8f22d62d470f12ab5c2ea894fd524e8173504de7d0f70e74827dd8d92
```
Проверяю:  
```bash
# docker ps
CONTAINER ID   IMAGE                COMMAND                  CREATED              STATUS              PORTS                                   NAMES
741dbeb8f22d   nicko-nginx-docker   "/docker-entrypoint.…"   About a minute ago   Up About a minute   0.0.0.0:8888->80/tcp, :::8888->80/tcp   web
```  
Проверяю в браузере:  
![nicko-nginx-docker](nicko-nginx-docker.jpg)  
  
  
- Размещаю собственный образ nginx в репозитории docker:  
Логинюсь:  
```bash
# docker login
```
   
Устанавливаю tag:  
```bash
# docker tag nicko-nginx-docker nicko2003/devops-netology:nicko-nginx-docker
```  
Загружаю образ в репозиторий:  
```bash
# docker push nicko2003/devops-netology:nicko-nginx-docker
The push refers to repository [docker.io/nicko2003/devops-netology]
ca5fc0181534: Pushed 
a059c9abe376: Pushed 
09be960dcde4: Pushed 
18be1897f940: Pushed 
dfe7577521f0: Pushed 
d253f69cb991: Pushed 
fd95118eade9: Pushed 
nicko-nginx-docker: digest: sha256:44199922035dff2ed936d519550b8d7f72fe4aeee892364a6cb84bf2f65a9c87 size: 1777
```
  
![nicko-nginx-docker_pushed](nicko-nginx-docker-pushed.png)  
  

### Задача 2  

Посмотрите на сценарий ниже и ответьте на вопрос: "Подходит ли в этом сценарии использование Docker контейнеров или лучше подойдет виртуальная машина, физическая машина? Может быть возможны разные варианты?"

Детально опишите и обоснуйте свой выбор.

--

Сценарий:  

- Высоконагруженное монолитное java веб-приложение;  
```
Выбираю физический сервер или ВМ, т.к. монолитное приложение тяжеловесно, как правило выполняется в несколько потоков.
```
- Nodejs веб-приложение;  
```
Подойдет Docker. Простота развертывания приложения, лёгковесность и масштабирование.
```
- Мобильное приложение c версиями для Android и iOS;  
```
Думаю, что ВМ, т.к. приложение в докере не имеет GUI
```  
- Шина данных на базе Apache Kafka;  
```
Думаю, что можно использовать в докере. Брокеры активно используются в современных распределённых приложениях, доставка приложения через докер на сервера и разработчикам в тестовую среду должна упростить жизнь.
```  
- Elasticsearch кластер для реализации логирования продуктивного веб-приложения - три ноды elasticsearch, два logstash и две ноды kibana;  
```
Docker подойдёт лучше, так как он будет удобней для кластеризации.  
```
- Мониторинг-стек на базе Prometheus и Grafana;  
```
Prometheus и Grafanaсами системы не хранят как таковых данны, можно развернуть на Докере
```
- MongoDB, как основное хранилище данных для java-приложения;  
```
Виртуальная машина, ввиду сложности администрирования MongoDB внутри контейнера и вероятности потери данных при потере контейнера.
```
- Gitlab сервер для реализации CI/CD процессов и приватный (закрытый) Docker Registry.  
```
Docker не подходит в данном случае, т.к. при потере контейнера будет сложно восстановить частоизменяемые данные. Здесь больше подходят физические или виртуальные сервера.
```
  
### Задача 3  

- Запустите первый контейнер из образа centos c любым тэгом в фоновом режиме, подключив папку /data из текущей рабочей директории на хостовой машине в /data контейнера;  
- Запустите второй контейнер из образа debian в фоновом режиме, подключив папку /data из текущей рабочей директории на хостовой машине в /data контейнера;  
- Подключитесь к первому контейнеру с помощью docker exec и создайте текстовый файл любого содержания в /data;  
- Добавьте еще один файл в папку /data на хостовой машине;  
- Подключитесь во второй контейнер и отобразите листинг и содержание файлов в /data контейнера.  

### Решение.  
 - Запускаю контейнер с Centos:  
```bash
# docker run -v ~/netology/docker_volume/data:/data -dt --name centos_vol centos
59a7d461be3d8975869e86f368a876471539f216bf611acb5e0a39e6893256ca
```
  
 - Запускаю контейнер с Debian:  
```bash
# docker run -v ~/netology/docker_volume/data:/data -dt --name debian_vol debian
Unable to find image 'debian:latest' locally
latest: Pulling from library/debian
67e8aa6c8bbc: Pull complete 
Digest: sha256:6137c67e2009e881526386c42ba99b3657e4f92f546814a33d35b14e60579777
Status: Downloaded newer image for debian:latest
eaee1f76e034baed0bce6f0cd890a1a07513067828b0de6439562101ec2bd559

```
  
Контейнеры запущены: 
```bash
# docker ps 
CONTAINER ID   IMAGE                COMMAND                  CREATED              STATUS              PORTS                                   NAMES
eaee1f76e034   debian               "bash"                   About a minute ago   Up About a minute                                           debian_vol
59a7d461be3d   centos               "/bin/bash"              2 minutes ago        Up 2 minutes                                                centos_vol
741dbeb8f22d   nicko-nginx-docker   "/docker-entrypoint.…"   30 hours ago         Up 30 hours         0.0.0.0:8888->80/tcp, :::8888->80/tcp   web
```

- Подключаюсь к первому контейнеру и создаю текстовый файл:  
```bash
# docker exec -it centos_vol /bin/bash 
[root@59a7d461be3d /]# echo "Example1" > /data/Example1.txt
```
  
- Добавляю текстовый файл на хост-машине:  
```bash
# echo "Example2" > ~/netology/docker_volume/data/Example2.txt
```
  
- Подключаюсь ко второму контейнеру и проверяю наличие файлов:  
```bash
# docker exec -it debian_vol /bin/bash 
root@eaee1f76e034:/# ls -l /data
total 8
-rw-r--r-- 1 root root 9 May 20 09:36 Example1.txt
-rw-r--r-- 1 root root 9 May 20 09:39 Example2.txt
```