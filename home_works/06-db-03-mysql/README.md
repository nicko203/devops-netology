# Домашнее задание к занятию "6.3. MySQL"

## Введение

Перед выполнением задания вы можете ознакомиться с 
[дополнительными материалами](https://github.com/netology-code/virt-homeworks/tree/master/additional/README.md).

## Задача 1

Используя docker поднимите инстанс MySQL (версию 8). Данные БД сохраните в volume.  


Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-03-mysql/test_data) и 
восстановитесь из него.

Перейдите в управляющую консоль `mysql` внутри контейнера.

Используя команду `\h` получите список управляющих команд.

Найдите команду для выдачи статуса БД и **приведите в ответе** из ее вывода версию сервера БД.

Подключитесь к восстановленной БД и получите список таблиц из этой БД.

**Приведите в ответе** количество записей с `price` > 300.

В следующих заданиях мы будем продолжать работу с данным контейнером.


## Решение:  


Docker-compose манифест:  

```bash
# cat ./mysql-docker-compose.yml 
version: '3.7'

services:

  mysql8:
    image: mysql:8
    container_name: mysql-8-netology
    command: --default-authentication-plugin=mysql_native_password
    restart: always
    environment:
        MYSQL_ROOT_PASSWORD: mx32nUsp
    volumes:
        - ./data:/var/lib/mysql
        - ./dumps:/dumps
    ports:
        - "3306:3306"
    deploy:
        resources:
            limits:
                cpus: '2'
                memory: 4G
```

Запускаю контейнер:  
```bash
# docker-compose -f mysql-docker-compose.yml up -d

# docker ps
CONTAINER ID   IMAGE     COMMAND                  CREATED          STATUS          PORTS                                                  NAMES
be0d8acf78dc   mysql:8   "docker-entrypoint.s…"   43 seconds ago   Up 38 seconds   0.0.0.0:3306->3306/tcp, :::3306->3306/tcp, 33060/tcp   mysql-8-netology

```

Подключаюсь к консоли контейнера:  
```bash
# docker exec -it mysql-8-netology bash
```
Подключаюсь к консоли MySQL:  
```bash
# mysql -h localhost -u root -p
Enter password: 
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 10
Server version: 8.0.29 MySQL Community Server - GPL

Copyright (c) 2000, 2022, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

```

Создаю "пустую" БД:  
```
mysql> CREATE DATABASE test_db CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
Query OK, 1 row affected (0.01 sec)
```

Загружаю дамп в БД test_db:
```
mysql> use test_db;
Database changed

mysql> source /dumps/test_dump.sql
```

Получение статуса СУБД:  
```
mysql> \s
--------------
mysql  Ver 8.0.29 for Linux on x86_64 (MySQL Community Server - GPL)

Connection id:		11
Current database:	test_db
Current user:		root@localhost
SSL:			Not in use
Current pager:		stdout
Using outfile:		''
Using delimiter:	;
Server version:		8.0.29 MySQL Community Server - GPL
Protocol version:	10
Connection:		Localhost via UNIX socket
Server characterset:	utf8mb4
Db     characterset:	utf8mb4
Client characterset:	latin1
Conn.  characterset:	latin1
UNIX socket:		/var/run/mysqld/mysqld.sock
Binary data as:		Hexadecimal
Uptime:			24 min 27 sec

Threads: 2  Questions: 46  Slow queries: 0  Opens: 162  Flush tables: 3  Open tables: 80  Queries per second avg: 0.031
```

Список таблиц в БД test_db:  
```
mysql> use test_db;
Database changed

mysql> SHOW TABLES;
+-------------------+
| Tables_in_test_db |
+-------------------+
| orders            |
+-------------------+
1 row in set (0.01 sec)

```

Количество записей  записей с price > 300:  
```
mysql> SELECT COUNT(*) FROM orders WHERE price > 300;
+----------+
| COUNT(*) |
+----------+
|        1 |
+----------+
1 row in set (0.00 sec)

```

## Задача 2

Создайте пользователя test в БД c паролем test-pass, используя:
- плагин авторизации mysql_native_password
- срок истечения пароля - 180 дней 
- количество попыток авторизации - 3 
- максимальное количество запросов в час - 100
- аттрибуты пользователя:
    - Фамилия "Pretty"
    - Имя "James"

```
CREATE USER 'test'@'localhost' 
    IDENTIFIED WITH mysql_native_password BY 'test-pass'
    WITH MAX_CONNECTIONS_PER_HOUR 100
    PASSWORD EXPIRE INTERVAL 180 DAY
    FAILED_LOGIN_ATTEMPTS 3
    ATTRIBUTE '{"first_name":"James", "last_name":"Pretty"}';
```

Предоставьте привелегии пользователю `test` на операции SELECT базы `test_db`.

```
mysql> GRANT SELECT ON test_db.* to 'test'@'localhost';
Query OK, 0 rows affected, 1 warning (0.00 sec)
```

    
Используя таблицу INFORMATION_SCHEMA.USER_ATTRIBUTES получите данные по пользователю `test` и 
**приведите в ответе к задаче**.

```
mysql> SELECT * FROM information_schema.user_attributes WHERE user LIKE '%test%';
+------+-----------+------------------------------------------------+
| USER | HOST      | ATTRIBUTE                                      |
+------+-----------+------------------------------------------------+
| test | localhost | {"last_name": "Pretty", "first_name": "James"} |
+------+-----------+------------------------------------------------+
1 row in set (0.00 sec)

```

## Задача 3

Установите профилирование `SET profiling = 1`.  
```
mysql> SET profiling = 1;
```

Изучите вывод профилирования команд `SHOW PROFILES;`.  
```
mysql> SHOW PROFILES;
+----------+------------+----------------------+
| Query_ID | Duration   | Query                |
+----------+------------+----------------------+
|        1 | 0.00011350 | SELECT * FROM orders |
|        2 | 0.00023275 | SELECT DATABASE()    |
|        3 | 0.00182900 | show databases       |
|        4 | 0.00182975 | show tables          |
+----------+------------+----------------------+
4 rows in set, 1 warning (0.00 sec)

```

Исследуйте, какой `engine` используется в таблице БД `test_db` и **приведите в ответе**.  
```
> SELECT table_schema, table_name, engine FROM information_schema.tables WHERE table_name = 'orders';
+--------------+------------+--------+
| TABLE_SCHEMA | TABLE_NAME | ENGINE |
+--------------+------------+--------+
| test_db      | orders     | InnoDB |
+--------------+------------+--------+
1 row in set (0.00 sec)
```

Измените `engine` и **приведите время выполнения и запрос на изменения из профайлера в ответе**:
- на `MyISAM`
- на `InnoDB`

```
mysql> ALTER TABLE orders ENGINE = MyIsam;
Query OK, 5 rows affected (0.02 sec)
Records: 5  Duplicates: 0  Warnings: 0

mysql> ALTER TABLE orders ENGINE =InnoDB;
Query OK, 5 rows affected (0.02 sec)
Records: 5  Duplicates: 0  Warnings: 0
```

```
mysql> SHOW PROFILES;
+----------+------------+----------------------------------------------------------------------------------------------------+
| Query_ID | Duration   | Query                                                                                              |
+----------+------------+----------------------------------------------------------------------------------------------------+
|        1 | 0.00011350 | SELECT * FROM orders                                                                               |
|        2 | 0.00023275 | SELECT DATABASE()                                                                                  |
|        3 | 0.00182900 | show databases                                                                                     |
|        4 | 0.00182975 | show tables                                                                                        |
|        5 | 0.01035125 | SELECT TABLE_NAME, ENGINE FROM information_schema.TABLES                                           |
|        6 | 0.20537625 | SELECT * FROM information_schema.TABLES                                                            |
|        7 | 0.00742275 | SELECT table_schema, table_name, engine FROM information_schema.TABLES                             |
|        8 | 0.00170525 | SELECT table_schema, table_name, engine FROM information_schema.tables WHERE table_name = 'orders' |
|        9 | 0.02397575 | ALTER TABLE orders ENGINE = MyIsam                                                                 |
|       10 | 0.02001625 | ALTER TABLE orders ENGINE =InnoDB                                                                  |
+----------+------------+----------------------------------------------------------------------------------------------------+
10 rows in set, 1 warning (0.00 sec)
```

## Задача 4 

Изучите файл `my.cnf` в директории /etc/mysql.  

Измените его согласно ТЗ (движок InnoDB):
- Скорость IO важнее сохранности данных
- Нужна компрессия таблиц для экономии места на диске
- Размер буффера с незакомиченными транзакциями 1 Мб
- Буффер кеширования 30% от ОЗУ ( ОЗУ 4 ГБ)
- Размер файла логов операций 100 Мб

Приведите в ответе измененный файл `my.cnf`.

```
[mysqld]
pid-file        = /var/run/mysqld/mysqld.pid
socket          = /var/run/mysqld/mysqld.sock
datadir         = /var/lib/mysql
secure-file-priv= NULL

# Custom config should go here
!includedir /etc/mysql/conf.d/

innodb_flush_method = O_DSYNC
innodb_flush_log_at_trx_commit = 2
innodb_file_per_table = ON
innodb_log_buffer_size = 1048576
innodb_buffer_pool_size = 1431655765
innodb_log_file_size = 104857600
```


---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
