## Домашнее задание к занятию "3.6. Компьютерные сети, лекция 1"  

### 1. Работа c HTTP через телнет.
### Подключитесь утилитой телнет к сайту stackoverflow.com telnet stackoverflow.com 80
### отправьте HTTP запрос
### GET /questions HTTP/1.0
### HOST: stackoverflow.com
### В ответе укажите полученный HTTP код, что он означает?

Полученный ответ:  
**_HTTP/1.1 301 Moved Permanently_**  
**_cache-control: no-cache, no-store, must-revalidate_**  
**_location: https://stackoverflow.com/questions_**  

На сервере настроен редирект с HTTP на HTTPS.  

### 2. Повторите задание 1 в браузере, используя консоль разработчика F12.  

**_Код ответа 307_**  

![stackoverflow_head](stackoverflow_head.png)  

![stackoverflow_network](stackoverflow_network.png)  