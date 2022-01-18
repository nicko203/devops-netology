## Домашнее задание к занятию "3.2. Работа в терминале, лекция 2"

### 1. Какого типа команда cd? Попробуйте объяснить, почему она именно такого типа; опишите ход своих мыслей, если считаете что она могла бы быть другого типа.

$ type cd
cd is a shell builtin

cd — это встроенная команда bash

Встроенная команда - это команда, которую оболочка выполняет сама, вместо того, чтобы интерпретировать ее как запрос на загрузку и запуск какой-либо другой программы( со своим pid ) .
Это имеет два основных эффекта. Во-первых, обычно это быстрее, потому что загрузка и запуск программы требуют времени.
Во-вторых, встроенная команда может влиять на внутреннее состояние оболочки. Вот почему такие команды cd должны быть встроенными, потому что внешняя программа не может изменить текущий каталог оболочки.


### 2. Какая альтернатива без pipe команде grep <some_string> <some_file> | wc -l? man grep поможет в ответе на этот вопрос. Ознакомьтесь с документом о других подобных некорректных вариантах использования pipe.

Команда grep <some_string> <some_file> | wc -l выполняет следующие действия:
- grep <some_string> <some_file>   - производи поиск подстроки <some_string> в файле <some_file> и выводит в консоль полные строки, содержащие подстроку;
- wc -l - подсчитывает количество выведенных строк, возвращает число.

Альтернативная команда: grep -с <some_string> <some_file>


### 3. Какой процесс с PID 1 является родителем для всех процессов в вашей виртуальной машине Ubuntu 20.04?

$ pstree -p

systemd(1)-+-VBoxService(829)-

           |

           |-accounts-daemon(624)-

           |

### 4. Как будет выглядеть команда, которая перенаправит вывод stderr ls на другую сессию терминала?

$ ls -l \abracadabra 2>/dev/pts/2

Вывод в терминале pts/2:
ls: невозможно получить доступ к 'abracadabra': Нет такого файла или каталога


### 5. Получится ли одновременно передать команде файл на stdin и вывести ее stdout в другой файл? Приведите работающий пример.

Содержимое файла test.txt:

**_$ cat ./test.txt_**

aaaAaaa

dddDddd

hhhHhhh

Передаём  test.txt на вход команды grep , результат выводим в out.log

**_$ grep "aAa" <./test.txt > ./out.log_**

**_$ cat ./out.log_**

aaaAaaa

### 6. Получится ли находясь в графическом режиме, вывести данные из PTY в какой-либо из эмуляторов TTY? Сможете ли вы наблюдать выводимые данные?

### 11. Узнайте, какую наиболее старшую версию набора инструкций SSE поддерживает ваш процессор с помощью /proc/cpuinfo.

**_$ cat /proc/cpuinfo | grep  -i SSE_**

Старшая версия SSE: sse4_2

