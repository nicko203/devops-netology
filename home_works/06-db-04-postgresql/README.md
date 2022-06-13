# Домашнее задание к занятию "6.4. PostgreSQL"

## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 13). Данные БД сохраните в volume.

Подключитесь к БД PostgreSQL используя `psql`.

Воспользуйтесь командой `\?` для вывода подсказки по имеющимся в `psql` управляющим командам.

**Найдите и приведите** управляющие команды для:
- вывода списка БД
- подключения к БД
- вывода списка таблиц
- вывода описания содержимого таблиц
- выхода из psql


## Решение:  

Docker compose манифест:  
```
# cat ./pg13-docker-compose.yml 
version: '3.7'

services:
    postgres13:
        image: postgres:13
        container_name: postgresql-13-netology
        restart: always
        environment:
            POSTGRES_PASSWORD: postgres
            POSTGRES_DB: netology
        volumes:
            - ./data:/var/lib/postgresql/data
            - ./dumps:/var/lib/postgresql/dumps
        ports:
            - "5432:5432"
        deploy:
            resources:
                limits:
                    cpus: '2'
                    memory: 4G

```

```bash
# docker ps 
CONTAINER ID   IMAGE         COMMAND                  CREATED         STATUS         PORTS                                                  NAMES
4c395321a1dc   postgres:13   "docker-entrypoint.s…"   7 minutes ago   Up 7 minutes   0.0.0.0:5432->5432/tcp, :::5432->5432/tcp              postgresql-13-netology
```
Подключаюсь к консоли контейнера:  
```bash
# docker exec -it postgresql-13-netology bash
```
Подключаюсь к консоли PostgreSQL:  
```
# psql -h localhost -U postgres
psql (13.7 (Debian 13.7-1.pgdg110+1))
Type "help" for help.

```

Вывод списка БД:  
```
postgres=# \l
                                 List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges   
-----------+----------+----------+------------+------------+-----------------------
 netology  | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
(4 rows)

```

Подключение к БД netology:  
```
postgres=# \c netology
You are now connected to database "netology" as user "postgres".
```

Список таблиц:
```
netology=# CREATE TABLE test (id SERIAL PRIMARY KEY, name TEXT);
CREATE TABLE


netology=# \dt
        List of relations
 Schema | Name | Type  |  Owner   
--------+------+-------+----------
 public | test | table | postgres
(1 row)


```

Вывод описания содержимого таблицы:
```
netology=# \d test
                            Table "public.test"
 Column |  Type   | Collation | Nullable |             Default              
--------+---------+-----------+----------+----------------------------------
 id     | integer |           | not null | nextval('test_id_seq'::regclass)
 name   | text    |           |          | 
Indexes:
    "test_pkey" PRIMARY KEY, btree (id)
```

Выход из консоли: 
```
netology=# \q
root@4c395321a1dc:/#
```

## Задача 2

Используя `psql` создайте БД `test_database`.

Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-04-postgresql/test_data).

Восстановите бэкап БД в `test_database`.

Перейдите в управляющую консоль `psql` внутри контейнера.

Подключитесь к восстановленной БД и проведите операцию ANALYZE для сбора статистики по таблице.

Используя таблицу [pg_stats](https://postgrespro.ru/docs/postgresql/12/view-pg-stats), найдите столбец таблицы `orders` 
с наибольшим средним значением размера элементов в байтах.

**Приведите в ответе** команду, которую вы использовали для вычисления и полученный результат.


## Решение:

Создание БД test_database:
```
postgres=# CREATE DATABASE test_database;
CREATE DATABASE

```

Восстановление бэкапа БД в test_database:  
```bash
# psql -h localhost -U postgres test_database < /var/lib/postgresql/dumps/test_dump.sql 
SET
SET
SET
SET
SET
 set_config 
------------
 
(1 row)

SET
SET
SET
SET
SET
SET
CREATE TABLE
ALTER TABLE
CREATE SEQUENCE
ALTER TABLE
ALTER SEQUENCE
ALTER TABLE
COPY 8
 setval 
--------
      8
(1 row)

ALTER TABLE
```

Операция ANALYZE для сбора статистики по таблице orders:

```
test_database=# ANALYZE VERBOSE orders;
INFO:  analyzing "public.orders"
INFO:  "orders": scanned 1 of 1 pages, containing 8 live rows and 0 dead rows; 8 rows in sample, 8 estimated total rows
ANALYZE
```

Столбец таблицы orders с наибольшим средним значением размера элементов в байтах:  

```
test_database=# SELECT attname, avg_width FROM pg_stats WHERE tablename = 'orders' order by avg_width desc limit 1;
 attname | avg_width 
---------+-----------
 title   |        16
(1 row)

```


## Задача 3

Архитектор и администратор БД выяснили, что ваша таблица orders разрослась до невиданных размеров и
поиск по ней занимает долгое время. Вам, как успешному выпускнику курсов DevOps в нетологии предложили
провести разбиение таблицы на 2 (шардировать на orders_1 - price>499 и orders_2 - price<=499).

Предложите SQL-транзакцию для проведения данной операции.

```
begin;

  -- переименование "старой"  orders
  alter table public.orders rename to orders_old;

  -- создание новой orders с партиционированием
  create table public.orders (
      like public.orders_old
      including defaults
      including constraints
      including indexes
  );

  create table public.orders_1 (
      check (price>499)
  ) inherits (public.orders);

  create table public.orders_2 (
      check (price<=499)
  ) inherits (public.orders);

  ALTER TABLE public.orders_1 OWNER TO postgres;
  ALTER TABLE public.orders_2 OWNER TO postgres;

  create rule orders_insert_over_499 as on insert to public.orders
  where (price>499)
  do instead insert into public.orders_1 values(NEW.*);

  create rule orders_insert_499_or_less as on insert to public.orders
  where (price<=499)
  do instead insert into public.orders_2 values(NEW.*);

  -- копирование данных из старой в новую
  insert into public.orders (id,title,price) select id,title,price from public.orders_old;

  -- перепривязывание SEQUENCE
  alter table public.orders_old alter id drop default;
  ALTER SEQUENCE public.orders_id_seq OWNED BY public.orders.id;

  -- удаление старой orders
  drop table public.orders_old;

end;
```

Можно ли было изначально исключить "ручное" разбиение при проектировании таблицы orders?  
Да, "ручного" разбиения можно было избежать при проектировании таблицы путём введения секционирования до внесения данных в таблицу.  

## Задача 4

Используя утилиту `pg_dump` создайте бекап БД `test_database`.  

```bash
# pg_dump -h localhost -U postgres test_database > /var/lib/postgresql/dumps/test_dump_new.sql
```

Как бы вы доработали бэкап-файл, чтобы добавить уникальность значения столбца `title` для таблиц `test_database`?
```
alter table orders_1 add constraint orders_1_title_unique unique (title);

alter table orders_2 add constraint orders_2_title_unique unique (title);
```
---

### Как cдавать задание

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
