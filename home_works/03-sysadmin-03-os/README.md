## Домашнее задание к занятию "3.3. Операционные системы, лекция 1"  


### 1. Какой системный вызов делает команда cd? В прошлом ДЗ мы выяснили, что cd не является самостоятельной программой, это shell builtin, поэтому запустить strace непосредственно на cd не получится. Тем не менее, вы можете запустить strace на /bin/bash -c 'cd /tmp'. В этом случае вы увидите полный список системных вызовов, которые делает сам bash при старте. Вам нужно найти тот единственный, который относится именно к cd. Обратите внимание, что strace выдаёт результат своей работы в поток stderr, а не в stdout.  

Системный вызов **_chdir("/tmp")_**  


### 2. Попробуйте использовать команду file на объекты разных типов на файловой системе. Используя strace выясните, где находится база данных file на основании которой она делает свои догадки.

Файл базы данных: **_/usr/share/misc/magic.mgc_**  

Системный вызов: **_openat(AT_FDCWD, "/usr/share/misc/magic.mgc", O_RDONLY) = 3_**  

### 3. Предположим, приложение пишет лог в текстовый файл. Этот файл оказался удален (deleted в lsof), однако возможности сигналом сказать приложению переоткрыть файлы или просто перезапустить приложение – нет. Так как приложение продолжает писать в удаленный файл, место на диске постепенно заканчивается. Основываясь на знаниях о перенаправлении потоков предложите способ обнуления открытого удаленного файла (чтобы освободить место на файловой системе).

Пробую реализовать на примере редактора vi.  
Открываю файл в редакторе vi, определяю PID процесса vi:  

**_$ ps ax | grep 123_**  
**_9620 pts/11   S+     0:00 vi ./\_123.txt_**  
**_9648 pts/6    S+     0:00 grep 123_**  


**_$ lsof | grep "\_123"_**  
**_vi         9620                            nicko    4u      REG                8,1     16384         13239247 /home/nicko/tmp1/.\_123.txt.swp_**  


**_# ls -l_**  
**_итого 0_**  
**_lrwx------ 1 nicko nicko 64 янв 25 10:44 0 -> /dev/pts/11_**  
**_lrwx------ 1 nicko nicko 64 янв 25 10:44 1 -> /dev/pts/11_**  
**_l-wx------ 1 nicko nicko 64 янв 25 10:44 10 -> 'pipe:[47928526]'_**  
**_lrwx------ 1 nicko nicko 64 янв 25 10:44 2 -> /dev/pts/11_**  
**_lrwx------ 1 nicko nicko 64 янв 25 10:44 4 -> /home/nicko/tmp1/.\_123.txt.swp_**  
**_lrwx------ 1 nicko nicko 64 янв 25 10:44 5 -> /dev/pts/4_**  
**_lrwx------ 1 nicko nicko 64 янв 25 10:44 6 -> /dev/pts/4_**  

Удаляю файл и проверяю состояние:  

**_$ rm /home/nicko/tmp1/.\_123.txt.swp_**  

**_$ lsof | grep "\_123"_**  
**_vi         9620                            nicko    4u      REG                8,1     16384         13239247 /home/nicko/tmp1/.\_123.txt.swp (deleted)_**  

Файл помечен как удалённый, но место на диске по прежнему занимает.  

Затираю файл  через поток и проверяю состояние:  

**_$ echo '' > /proc/9620/fd/4_**  

**_$ lsof | grep "\_123"_**  
**_vi         9620                            nicko    4u      REG                8,1         1         13239247 /home/nicko/tmp1/.\_123.txt.swp (deleted)_**  

Место освобожденно.  

### 4. Занимают ли зомби-процессы какие-то ресурсы в ОС (CPU, RAM, IO)?  

Зомби-процесс существует до тех пор, пока родительский процесс не прочитает его статус с помощью системного вызова wait(), в результате чего запись в таблице процессов будет освобождена.  
Зомби не занимают памяти (как процессы-сироты), но блокируют записи в таблице процессов, размер которой ограничен для каждого пользователя и системы в целом.  


### 5. В iovisor BCC есть утилита opensnoop:  
### root@vagrant:~# dpkg -L bpfcc-tools | grep sbin/opensnoop  
### /usr/sbin/opensnoop-bpfcc  
### На какие файлы вы увидели вызовы группы open за первую секунду работы утилиты? Воспользуйтесь пакетом bpfcc-tools для Ubuntu 20.04.  

root@pc:/home/nicko/EDU/NETOLOGY/DevOps# /usr/sbin/opensnoop-bpfcc -d 1  
PID    COMM               FD ERR PATH  
2342   cinnamon           22   0 /proc/self/stat  
262    systemd-journal    -1   2 /var/log/journal/68297b98edf445cbaf700c004969a88c/system.journal  
262    systemd-journal    -1   2 /var/log/journal/68297b98edf445cbaf700c004969a88c/system.journal  
2342   cinnamon           22   0 /proc/self/stat  
3330   proftpd            -1   2 /etc/shutmsg  
2342   cinnamon           22   0 /proc/self/stat  
2342   cinnamon           22   0 /proc/self/stat  
2342   cinnamon           22   0 /proc/self/stat  
2342   cinnamon           22   0 /proc/self/stat  


### 6. Какой системный вызов использует uname -a? Приведите цитату из man по этому системному вызову, где описывается альтернативное местоположение в /proc, где можно узнать версию ядра и релиз ОС.

Системный вызов uname()  
Part of the utsname information is also accessible via /proc/sys/kernel/{ostype, hostname, osrelease, version, domainname}.


### 7. Чем отличается последовательность команд через ; и через && в bash? Есть ли смысл использовать в bash &&, если применить set -e?

Последовательность команд через *_;_* выполняется одна за другой в независимости от результата выполнения предыдущей команды.  
В последовательности команд через *_&&_* следующая команда выполняется только при удачном выполнении предыдущей команды(возвращается код *_0_*) .  

Команда *_set -e_* остановит скрипт, если при его выполнении возникнет ошибка,  поэтому использовать *_&&_* с *_set -e_* смысла нет.


### 8. Из каких опций состоит режим bash set -euxo pipefail и почему его хорошо было бы использовать в сценариях?

-e Немедленно завершается работа, если команда завершается с ненулевым статусом.  
-u неустановленные/не заданные параметры и переменные считаются как ошибки, с выводом в stderr текста ошибки и выполнит завершение неинтерактивного вызова  
-x вывод команд и их аргументов по мере их выполнения.  
-o pipefail возвращаемое значение конвейера - это статус последней команды, завершенной с ненулевым статусом, или ноль, если ни одна команда не завершилась с ненулевым статусом.

Повышается детализация вывода, выполнение программы завершается при возникновеннии ошибки на любом этапе.

### 9. Используя -o stat для ps, определите, какой наиболее часто встречающийся статус у процессов в системе. В man ps ознакомьтесь (/PROCESS STATE CODES) что значат дополнительные к основной заглавной буквы статуса процессов. Его можно не учитывать при расчете (считать S, Ss или Ssl равнозначными).

Наиболее часто встречаются процессы со статусом S* - 249 процессов
На втором месте процессы со статусом I* - 51 процесс.

S - interruptible sleep (waiting for an event to complete)  
I - бездействующий процесс ядра.
