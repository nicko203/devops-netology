## Домашнее задание к занятию "3.4. Операционные системы, лекция 2"  

### 1. На лекции мы познакомились с node_exporter. В демонстрации его исполняемый файл запускался в background. Этого достаточно для демо, но не для настоящей production-системы, где процессы должны находиться под внешним управлением. Используя знания из лекции по systemd, создайте самостоятельно простой unit-файл для node_exporter:  


1.1. Создан init-файл *_/etc/systemd/system/node_exporter.service_*:  

*_[Unit]_*  
*_Description=Node Exporter Service_*  
*_After=network.target_*  

*_[Service]_*  
*_Type=simple_*  
*_EnvironmentFile=-/etc/default/node_exporter_*  
*_ExecStart=/usr/local/bin/node_exporter $NODE_EXPORTER_OPTS_*  
*_ExecReload=/bin/kill -HUP $MAINPID_*  
*_Restart=on-failure_*  

*_[Install]_*  
*_WantedBy=multi-user.target_*  


1.2. Создан файл *_/etc/default/node_exporter_*  для передачи опций процессу:  

*_cat /etc/default/node_exporter_*  
NODE_EXPORTER_OPTS=  


1.3. Процесс добавлен в автозагрузку:  

*_systemctl enable node_exporter.service_*

1.4. Через *_systemctl_* процесс успешно стартует, останавливается, рестартует, переменные из внешнего файла передаются:  

![node_exporter](node_exporter.png)


### 2. Ознакомьтесь с опциями node_exporter и выводом /metrics по-умолчанию. Приведите несколько опций, которые вы бы выбрали для базового мониторинга хоста по CPU, памяти, диску и сети.  

Полный список метрик node_exporter получаем командой: *_curl 127.0.0.1:9100/metrics_*  

Для базового мониторинга хоста я бы выбрал:  

CPU:  
node_cpu_seconds_total{cpu="0",mode="idle"} 2.37368681e+06  
node_cpu_seconds_total{cpu="0",mode="iowait"} 28979.73  
node_cpu_seconds_total{cpu="0",mode="system"} 19975.73  
node_cpu_seconds_total{cpu="0",mode="user"} 78565.16  

ОЗУ:  
node_memory_MemTotal_bytes 6.152200192e+09  
node_memory_MemAvailable_bytes 1.234620416e+09  

Диск:  
node_disk_read_bytes_total{device="sda"} 1.68312164352e+11  
node_disk_write_time_seconds_total{device="sda"} 110996.581  
node_disk_read_time_seconds_total{device="sda"} 66134.383  

Сеть:  
node_network_info{address="2c:41:38:9e:bf:80",broadcast="ff:ff:ff:ff:ff:ff",device="eth0",duplex="full",ifalias="",operstate="up"} 1  
node_network_receive_bytes_total{device="eth0"} 6.7873508875e+10  
node_network_receive_drop_total{device="eth0"} 632192  
node_network_receive_errs_total{device="eth0"} 0  
node_network_transmit_bytes_total{device="eth0"} 8.079904087e+09  
node_network_transmit_drop_total{device="eth0"} 0  
node_network_transmit_errs_total{device="eth0"} 0  

### 3. Установите в свою виртуальную машину Netdata. Воспользуйтесь готовыми пакетами для установки (sudo apt install -y netdata). После успешной установки:  

Пакет *_netdata_* установлен. Проброшен порт 19999 с VM на хост-машину.  
Подключение из браузера к 127.0.0.1:19999  
![netdata](netdata.jpg)


### 4. Можно ли по выводу dmesg понять, осознает ли ОС, что загружена не на настоящем оборудовании, а на системе виртуализации?  

Да, можно. Вывод соотвествующих строк на скриншоте - используется KVM-виртуализация. На "железном" оборудовании строка имеет вид: "Booting paravirtualized kernel on bare hardware"  
  
![virtualized](virtualized.jpg)  


### 5. Как настроен sysctl fs.nr_open на системе по-умолчанию? Узнайте, что означает этот параметр. Какой другой существующий лимит не позволит достичь такого числа (ulimit --help)?  
  
*_$ sysctl fs.nr_open_*  
*_fs.nr_open = 1048576_*  

**_nr\_open_** - максимальное количество файлов, которое может быть выделено одним процессом.  

Кроме того, количество открытых файлов ограничивается:  
**_ulimit -Sn_** - "мягкий" лимит, максимальное количество файловых дескрипторов, которые могут быть открыты. Может быть увеличен.  
  
*_$ ulimit -Sn_*  
1024  

**_ulimit -Hn_** - "жёсткий" лимит, не может быть больше fs.nr_open. Значение "жёсткого" лимита можно только уменьшить.  

*_$ ulimit -Hn_*  
1048576  

### 6. Запустите любой долгоживущий процесс (не ls, который отработает мгновенно, а, например, sleep 1h) в отдельном неймспейсе процессов; покажите, что ваш процесс работает под PID 1 через nsenter. Для простоты работайте в данном задании под root (sudo -i). Под обычным пользователем требуются дополнительные опции (--map-root-user) и т.д.  

Запускаю *_sleep 1h_* в новом пространстве имён: *_unshare --fork --pid --mount-proc sleep 1h_*  

В другой консоли выполняю:  
![nsenter](nsenter.png)  

### 7. Найдите информацию о том, что такое :(){ :|:& };:. Запустите эту команду в своей виртуальной машине Vagrant с Ubuntu 20.04 (это важно, поведение в других ОС не проверялось). Некоторое время все будет "плохо", после чего (минуты) – ОС должна стабилизироваться. Вызов dmesg расскажет, какой механизм помог автоматической стабилизации. Как настроен этот механизм по-умолчанию, и как изменить число процессов, которое можно создать в сессии?  

В действительности эта команда является логической бомбой. Она оперирует определением функции с именем *_:_*, которая вызывает сама себя дважды: один раз на переднем плане и один раз в фоне.  

Результат работы:  
![processes](processes.jpg)  

Сработал следующий механизм:  
![fork_rejected](fork_rejected.jpg)

Заложенное ограничение на создание процессов в параметре *_ulimit -u_*  
Изменить параметр можно командой *_ulimit -u N_*  