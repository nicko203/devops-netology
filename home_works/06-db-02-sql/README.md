# Домашнее задание к занятию "6.2. SQL"

## Введение

Перед выполнением задания вы можете ознакомиться с 
[дополнительными материалами](https://github.com/netology-code/virt-homeworks/tree/master/additional/README.md).

## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 12) c 2 volume, 
в который будут складываться данные БД и бэкапы.

Приведите получившуюся команду или docker-compose манифест.

docker-compose манифест **_docker-compose.yml_**:
```
version: '3.7'

services:
    postgres12:
        image: postgres:12
        container_name: postgresql-12-netology
        restart: always
        environment:
            POSTGRES_PASSWORD: postgres
            POSTGRES_DB: netology
        volumes:
            - ./data:/var/lib/postgresql/data
            - ./backup:/var/lib/postgresql/backup
        ports:
            - "5432:5432"
        deploy:
            resources:
                limits:
                    cpus: '2'
                    memory: 4G
```

Запуск: 
```
# docker-compose -f docker-compose.yml up -d
```

Проверка:
```
# docker-compose ps 
NAME                     COMMAND                  SERVICE             STATUS              PORTS
postgresql-12-netology   "docker-entrypoint.s…"   postgres12          running             0.0.0.0:5432->5432/tcp, :::5432->5432/tcp
```


## Задача 2

В БД из задачи 1:  
- создайте пользователя test-admin-user и БД test_db  

```
postgres=# CREATE USER "test-admin-user" WITH PASSWORD 'ChangeThisPassword';
postgres=# CREATE DATABASE test_db;
```

- в БД test_db создайте таблицу orders и clients (спeцификация таблиц ниже)  
```
postgres=# \c test_db
Пароль пользователя postgres: 
psql (12.3 (Ubuntu 12.3-7.1C), сервер 12.11 (Debian 12.11-1.pgdg110+1))
Вы подключены к базе данных "test_db" как пользователь "postgres".


test_db=# CREATE TABLE orders (id SERIAL PRIMARY KEY, наименование TEXT,  цена INT);
CREATE TABLE
test_db=# CREATE TABLE clients(id SERIAL PRIMARY KEY, фамилия TEXT, страна_проживания TEXT, заказ INT, CONSTRAINT fk_orders FOREIGN KEY (заказ) REFERENCES orders (id));
CREATE TABLE
test_db=# CREATE INDEX страна_проживания_idx ON clients(страна_проживания);
CREATE INDEX

```

- предоставьте привилегии на все операции пользователю test-admin-user на таблицы БД test_db  
```
test_db=# GRANT ALL PRIVILEGES ON DATABASE test_db TO "test-admin-user";
GRANT
test_db=# GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO "test-admin-user";
GRANT
test_db=# GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO "test-admin-user";
GRANT
```

- создайте пользователя test-simple-user  
```
test_db=# CREATE USER "test-simple-user" WITH PASSWORD 'test-simple-user';
CREATE ROLE
```
- предоставьте пользователю test-simple-user права на SELECT/INSERT/UPDATE/DELETE данных таблиц БД test_db  
```
test_db=# GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO "test-simple-user";
GRANT
```

Таблица orders:  
- id (serial primary key)
- наименование (string)
- цена (integer)

Таблица clients:  
- id (serial primary key)
- фамилия (string)
- страна проживания (string, index)
- заказ (foreign key orders)

Приведите:  
- итоговый список БД после выполнения пунктов выше,  
```
test_db=# \l
                                      Список баз данных
    Имя    | Владелец | Кодировка | LC_COLLATE |  LC_CTYPE  |         Права доступа          
-----------+----------+-----------+------------+------------+--------------------------------
 netology  | postgres | UTF8      | en_US.utf8 | en_US.utf8 | 
 postgres  | postgres | UTF8      | en_US.utf8 | en_US.utf8 | 
 template0 | postgres | UTF8      | en_US.utf8 | en_US.utf8 | =c/postgres                   +
           |          |           |            |            | postgres=CTc/postgres
 template1 | postgres | UTF8      | en_US.utf8 | en_US.utf8 | =c/postgres                   +
           |          |           |            |            | postgres=CTc/postgres
 test_db   | postgres | UTF8      | en_US.utf8 | en_US.utf8 | =Tc/postgres                  +
           |          |           |            |            | postgres=CTc/postgres         +
           |          |           |            |            | "test-admin-user"=CTc/postgres
(5 строк)

```
- описание таблиц (describe)  
```
test_db=# \d orders
                                       Таблица "public.orders"
   Столбец    |   Тип   | Правило сортировки | Допустимость NULL |            По умолчанию            
--------------+---------+--------------------+-------------------+------------------------------------
 id           | integer |                    | not null          | nextval('orders_id_seq'::regclass)
 наименование | text    |                    |                   | 
 цена         | integer |                    |                   | 
Индексы:
    "orders_pkey" PRIMARY KEY, btree (id)
Ссылки извне:
    TABLE "clients" CONSTRAINT "fk_orders" FOREIGN KEY ("заказ") REFERENCES orders(id)

test_db=# \d clients
                                          Таблица "public.clients"
      Столбец      |   Тип   | Правило сортировки | Допустимость NULL |            По умолчанию             
-------------------+---------+--------------------+-------------------+-------------------------------------
 id                | integer |                    | not null          | nextval('clients_id_seq'::regclass)
 фамилия           | text    |                    |                   | 
 страна_проживания | text    |                    |                   | 
 заказ             | integer |                    |                   | 
Индексы:
    "clients_pkey" PRIMARY KEY, btree (id)
    "страна_проживания_idx" btree ("страна_проживания")
Ограничения внешнего ключа:
    "fk_orders" FOREIGN KEY ("заказ") REFERENCES orders(id)

```

- SQL-запрос для выдачи списка пользователей с правами над таблицами test_db  
```
test_db=# SELECT grantee, table_name, privilege_type FROM information_schema.table_privileges WHERE grantee in ('test-admin-user','test-simple-user') and table_name in ('clients','orders') order by grantee, table_name, privilege_type;
```

- список пользователей с правами над таблицами test_db  
```
     grantee      | table_name | privilege_type 
------------------+------------+----------------
 test-admin-user  | clients    | DELETE
 test-admin-user  | clients    | INSERT
 test-admin-user  | clients    | REFERENCES
 test-admin-user  | clients    | SELECT
 test-admin-user  | clients    | TRIGGER
 test-admin-user  | clients    | TRUNCATE
 test-admin-user  | clients    | UPDATE
 test-admin-user  | orders     | DELETE
 test-admin-user  | orders     | INSERT
 test-admin-user  | orders     | REFERENCES
 test-admin-user  | orders     | SELECT
 test-admin-user  | orders     | TRIGGER
 test-admin-user  | orders     | TRUNCATE
 test-admin-user  | orders     | UPDATE
 test-simple-user | clients    | DELETE
 test-simple-user | clients    | INSERT
 test-simple-user | clients    | SELECT
 test-simple-user | clients    | UPDATE
 test-simple-user | orders     | DELETE
 test-simple-user | orders     | INSERT
 test-simple-user | orders     | SELECT
 test-simple-user | orders     | UPDATE
(22 строки)
```

## Задача 3

Используя SQL синтаксис - наполните таблицы следующими тестовыми данными:  

Таблица orders  

|Наименование|цена|
|------------|----|
|Шоколад| 10 |
|Принтер| 3000 |
|Книга| 500 |
|Монитор| 7000|
|Гитара| 4000|

```
test_db=# INSERT INTO orders (наименование, цена) VALUES('Шоколад', 10),('Принтер', 3000),('Книга', 500),('Монитор', 7000),('Гитара', 4000);
INSERT 0 5

```

Таблица clients  

|ФИО|Страна проживания|
|------------|----|
|Иванов Иван Иванович| USA |
|Петров Петр Петрович| Canada |
|Иоганн Себастьян Бах| Japan |
|Ронни Джеймс Дио| Russia|
|Ritchie Blackmore| Russia|

```
test_db=# INSERT INTO clients (фамилия, страна_проживания) VALUES('Иванов Иван Иванович', 'USA'),('Петров Петр Петрович', 'Canada'),('Иоганн Себастьян Бах', 'Japan'),('Ронни Джеймс Дио', 'Russia'),('Ritchie Blackmore', 'Russia');
INSERT 0 5
```

Используя SQL синтаксис:
- вычислите количество записей для каждой таблицы 
- приведите в ответе:
    - запросы 
    - результаты их выполнения.
```
test_db=# SELECT COUNT(*) FROM orders;
 count 
-------
     5
(1 строка)
```
```
test_db=# SELECT COUNT(*) FROM clients;
 count 
-------
     5
(1 строка)
```

## Задача 4

Часть пользователей из таблицы clients решили оформить заказы из таблицы orders.

Используя foreign keys свяжите записи из таблиц, согласно таблице:

|ФИО|Заказ|
|------------|----|
|Иванов Иван Иванович| Книга |
|Петров Петр Петрович| Монитор |
|Иоганн Себастьян Бах| Гитара |

Приведите SQL-запросы для выполнения данных операций.  
```
test_db=# UPDATE clients SET заказ = (SELECT id FROM orders WHERE наименование = 'Книга') WHERE фамилия = 'Иванов Иван Иванович';
UPDATE 1
test_db=# UPDATE clients SET заказ = (SELECT id FROM orders WHERE наименование = 'Монитор') WHERE фамилия = 'Петров Петр Петрович';
UPDATE 1
test_db=# UPDATE clients SET заказ = (SELECT id FROM orders WHERE наименование = 'Гитара') WHERE фамилия = 'Иоганн Себастьян Бах';
UPDATE 1
```

Приведите SQL-запрос для выдачи всех пользователей, которые совершили заказ, а также вывод данного запроса.  
```
test_db=# SELECT c.*,o.наименование,o.цена FROM clients c JOIN orders o ON c.заказ = o.id;

 id |       фамилия        | страна_проживания | заказ | наименование | цена 
----+----------------------+-------------------+-------+--------------+------
  1 | Иванов Иван Иванович | USA               |     3 | Книга        |  500
  2 | Петров Петр Петрович | Canada            |     4 | Монитор      | 7000
  3 | Иоганн Себастьян Бах | Japan             |     5 | Гитара       | 4000
(3 строки)
```
 
Подсказка - используйте директиву `UPDATE`.

## Задача 5

Получите полную информацию по выполнению запроса выдачи всех пользователей из задачи 4  
(используя директиву EXPLAIN).  

Приведите получившийся результат и объясните что значат полученные значения.  
```
test_db=# EXPLAIN SELECT c.*,o.наименование,o.цена FROM clients c JOIN orders o ON c.заказ = o.id;
                               QUERY PLAN
-------------------------------------------------------------------------
 Hash Join  (cost=37.00..57.24 rows=810 width=108)
   Hash Cond: (c."заказ" = o.id)
   ->  Seq Scan on clients c  (cost=0.00..18.10 rows=810 width=72)
   ->  Hash  (cost=22.00..22.00 rows=1200 width=40)
         ->  Seq Scan on orders o  (cost=0.00..22.00 rows=1200 width=40)
```

Seq Scan on clients c  (cost=0.00..18.10 rows=810 width=72)  - будут прочитаны все записи из таблицы clients, cost=0.00 - ожидаемое время получения первой записи, 18.10 - ожидаемое время получения всех запаисей.  
Предполагаемое количество записей - 810.  
Seq Scan on orders o  (cost=0.00..22.00 rows=1200 width=40) - будут прочитаны все записи из таблицы orders, cost=0.00 - ожидаемое время получения первой записи, 22.00 - ожидаемое время получения всех запаисей.  
Предполагаемое количество записей - 1200.  


После выполнения команд  
```
test_db=# VACUUM ANALYZE  orders;
test_db=# VACUUM ANALYZE clients;
```

результат EXPLAIN стал более точным:  
```
test_db=# EXPLAIN SELECT c.*,o.наименование,o.цена FROM clients c JOIN orders o ON c.заказ = o.id;
                             QUERY PLAN
---------------------------------------------------------------------
 Hash Join  (cost=1.11..2.19 rows=5 width=64)
   Hash Cond: (c."заказ" = o.id)
   ->  Seq Scan on clients c  (cost=0.00..1.05 rows=5 width=47)
   ->  Hash  (cost=1.05..1.05 rows=5 width=21)
         ->  Seq Scan on orders o  (cost=0.00..1.05 rows=5 width=21)

```

## Задача 6

Создайте бэкап БД test_db и поместите его в volume, предназначенный для бэкапов (см. Задачу 1).

Остановите контейнер с PostgreSQL (но не удаляйте volumes).

Поднимите новый пустой контейнер с PostgreSQL.

Восстановите БД test_db в новом контейнере.

Приведите список операций, который вы применяли для бэкапа данных и восстановления. 

---

## Решение:

```bash
# docker ps
CONTAINER ID   IMAGE         COMMAND                  CREATED        STATUS        PORTS                                       NAMES
11a018c8a73a   postgres:12   "docker-entrypoint.s…"   19 hours ago   Up 19 hours   0.0.0.0:5432->5432/tcp, :::5432->5432/tcp   postgresql-12-netology
```

Захожу в оболочку контейнера:  
```bash
# docker exec -it postgresql-12-netology bash
root@11a018c8a73a:/# 
```

Создаю дамп БД test_db:  
```bash
root@11a018c8a73a:/# pg_dump -h localhost -U postgres -d test_db > /var/lib/postgresql/backup/_test_db.sql
root@11a018c8a73a:/# 
root@11a018c8a73a:/# 
root@11a018c8a73a:/# ls -l /var/lib/postgresql/backup/
total 8
-rw-r--r-- 1 root root 4796 Jun  8 03:53 _test_db.sql
```

Останавливаю контейнер:  
```bash
# docker-compose stop
```

Поднимаю новый пустой контейнер с PostgreSQL:  
Создаю манифест для нового экземпляра:  
```bash
# cat ./pg-second.yml 
version: '3.7'

services:
    postgres12:
        image: postgres:12
        container_name: postgresql-12-netology-new
        restart: always
        environment:
            POSTGRES_PASSWORD: postgres
            POSTGRES_DB: test_db
        volumes:
            - ./data_new:/var/lib/postgresql/data
            - ./backup:/var/lib/postgresql/backup
        ports:
            - "5432:5432"
        deploy:
            resources:
                limits:
                    cpus: '2'
                    memory: 4G
```
Запускаю контейнер:  
```bash
# docker-compose -f pg-second.yml up -d
[+] Running 1/1
 ⠿ Container postgresql-12-netology-new  Started       

# docker ps
CONTAINER ID   IMAGE         COMMAND                  CREATED         STATUS          PORTS                                       NAMES
3216beda6fd0   postgres:12   "docker-entrypoint.s…"   3 minutes ago   Up 35 seconds   0.0.0.0:5432->5432/tcp, :::5432->5432/tcp   postgresql-12-netology-new
```
Захожу в консоль контейнера:  
```bash
# docker exec -it postgresql-12-netology-new bash
```

Загружаю БД из дампа:  
```bash
# psql -h localhost -U postgres test_db < /var/lib/postgresql/backup/_test_db.sql
```

Проверяю:
```bash
# psql -h localhost -U postgres
psql (12.11 (Debian 12.11-1.pgdg110+1))
Type "help" for help.

postgres=# \l
                                 List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges   
-----------+----------+----------+------------+------------+-----------------------
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 test_db   | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
(4 rows)

postgres=# \c test_db
You are now connected to database "test_db" as user "postgres".

test_db=# \dt
          List of relations
 Schema |  Name   | Type  |  Owner   
--------+---------+-------+----------
 public | clients | table | postgres
 public | orders  | table | postgres
(2 rows)

test_db=# \d clients
                                  Table "public.clients"
      Column       |  Type   | Collation | Nullable |               Default               
-------------------+---------+-----------+----------+-------------------------------------
 id                | integer |           | not null | nextval('clients_id_seq'::regclass)
 фамилия           | text    |           |          | 
 страна_проживания | text    |           |          | 
 заказ             | integer |           |          | 
Indexes:
    "clients_pkey" PRIMARY KEY, btree (id)
    "страна_проживания_idx" btree ("страна_проживания")
Foreign-key constraints:
    "fk_orders" FOREIGN KEY ("заказ") REFERENCES orders(id)

test_db=# SELECT * FROM clients;
 id |       фамилия        | страна_проживания | заказ 
----+----------------------+-------------------+-------
  4 | Ронни Джеймс Дио     | Russia            |      
  5 | Ritchie Blackmore    | Russia            |      
  1 | Иванов Иван Иванович | USA               |     3
  2 | Петров Петр Петрович | Canada            |     4
  3 | Иоганн Себастьян Бах | Japan             |     5
(5 rows)


```

### Как cдавать задание

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
