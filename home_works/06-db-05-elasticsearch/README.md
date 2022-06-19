# Домашнее задание к занятию "6.5. Elasticsearch"

## Задача 1

В этом задании вы потренируетесь в:
- установке elasticsearch
- первоначальном конфигурировании elastcisearch
- запуске elasticsearch в docker

Используя докер образ [centos:7](https://hub.docker.com/_/centos) как базовый и 
[документацию по установке и запуску Elastcisearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/targz.html):

- составьте Dockerfile-манифест для elasticsearch
- соберите docker-образ и сделайте `push` в ваш docker.io репозиторий
- запустите контейнер из получившегося образа и выполните запрос пути `/` c хост-машины

Требования к `elasticsearch.yml`:
- данные `path` должны сохраняться в `/var/lib`
- имя ноды должно быть `netology_test`

В ответе приведите:
- текст Dockerfile манифеста
- ссылку на образ в репозитории dockerhub
- ответ `elasticsearch` на запрос пути `/` в json виде

Подсказки:
- возможно вам понадобится установка пакета perl-Digest-SHA для корректной работы пакета shasum
- при сетевых проблемах внимательно изучите кластерные и сетевые настройки в elasticsearch.yml
- при некоторых проблемах вам поможет docker директива ulimit
- elasticsearch в логах обычно описывает проблему и пути ее решения


## Решение:

- Dockerfile манифест:
```bash
# cat ./Dockerfile 
ARG OS_VERSION=7
ARG ES_VERSION=8.0.1

FROM centos:$OS_VERSION

ENV ES_VER=8.0.1
ENV ES_HOME=/opt/elasticsearch-${ES_VER}
ENV ES_JAVA_HOME=/opt/elasticsearch-${ES_VER}/jdk
ENV ES_JAVA_OPTS="-Xms128m -Xmx128m"
ENV PATH=$PATH:/opt/elasticsearch-${ES_VER}/bin

RUN yum update -y --setopt=tsflags=nodocs && \
yum install -y perl-Digest-SHA && \
yum install -y wget && \
rm -rf /var/cache/yum && \
groupadd elastic && \
useradd elastic -g elastic -p elasticsearch && \
mkdir -p /var/lib/elasticsearch/logs && \
mkdir -p /var/lib/elasticsearch/snapshots && \
mkdir -p /var/lib/elasticsearch/data

WORKDIR /opt

RUN wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-${ES_VER}-linux-x86_64.tar.gz && \
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-${ES_VER}-linux-x86_64.tar.gz.sha512 && \
shasum -a 512 -c elasticsearch-${ES_VER}-linux-x86_64.tar.gz.sha512 && \
tar -xzf elasticsearch-${ES_VER}-linux-x86_64.tar.gz && \
rm elasticsearch-${ES_VER}-linux-x86_64.tar.gz && \
chown -R elastic:elastic ${ES_HOME} && chown -R elastic:elastic /var/lib/elasticsearch

ADD elasticsearch.yml ${ES_HOME}/config/elasticsearch.yml

EXPOSE 9200 9300

WORKDIR ${ES_HOME}

USER elastic

CMD ["elasticsearch"]
```

Собираю образ:  
```bash
# docker build -t nicko-elasticsearch-docker .
```

- Образ собран: 
```bash
# docker images | grep elasticsearch
nicko-elasticsearch-docker   latest               ac7b251b6c77   3 minutes ago   1.5GB
```

- Размещаю собственный образ nginx в репозитории docker:  

Логинюсь:  
```bash
# docker login
```

Устанавливаю тег:  
```bash
# docker tag nicko-elasticsearch-docker nicko2003/devops-netology:nicko-elasticsearch-docker
```

Загружаю образ в репозиторий:  
```bash
# docker push nicko2003/devops-netology:nicko-elasticsearch-docker
The push refers to repository [docker.io/nicko2003/devops-netology]
ac739ea96873: Pushed 
a1d8ed2cf1e7: Pushed 
50dcf2920422: Pushed 
174f56854903: Mounted from library/centos 
nicko-elasticsearch-docker: digest: sha256:56e1c6f599807b17a2bb2ccf70803f0ac3d46dddc1ae81d3d1f585f0afc52a7f size: 1162
```

Ссылка на образ в репозитории dockerhub:  
https://hub.docker.com/layers/235041514/nicko2003/devops-netology/nicko-elasticsearch-docker/images/sha256-c6d587f77b53bace35f794a93c24d9d91689a333d559392f4163f17327490f8a?context=repo

Ответ elasticsearch на запрос пути / в json виде:  

```bash
# curl localhost:9200
{
  "name" : "netology_test",
  "cluster_name" : "netology_test_cluster",
  "cluster_uuid" : "O0u_f0GBQs2nxV72iq1DUg",
  "version" : {
    "number" : "8.0.1",
    "build_flavor" : "default",
    "build_type" : "tar",
    "build_hash" : "801d9ccc7c2ee0f2cb121bbe22ab5af77a902372",
    "build_date" : "2022-02-24T13:55:40.601285296Z",
    "build_snapshot" : false,
    "lucene_version" : "9.0.0",
    "minimum_wire_compatibility_version" : "7.17.0",
    "minimum_index_compatibility_version" : "7.0.0"
  },
  "tagline" : "You Know, for Search"
}
```

Далее мы будем работать с данным экземпляром elasticsearch.

## Задача 2

В этом задании вы научитесь:
- создавать и удалять индексы
- изучать состояние кластера
- обосновывать причину деградации доступности данных

Ознакомтесь с [документацией](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html) 
и добавьте в `elasticsearch` 3 индекса, в соответствии со таблицей:

| Имя | Количество реплик | Количество шард |
|-----|-------------------|-----------------|
| ind-1| 0 | 1 |
| ind-2 | 1 | 2 |
| ind-3 | 2 | 4 |

Добавляю индексы:  
```bash
# curl -H 'Content-Type: application/json'  -X PUT localhost:9200/ind-1 -d'
{
  "settings": {
    "index": {
      "number_of_shards": 1,  
      "number_of_replicas": 0 
    }
  }
}'
{"acknowledged":true,"shards_acknowledged":true,"index":"ind-1"}

# curl -H 'Content-Type: application/json'  -X PUT localhost:9200/ind-2 -d'
{
  "settings": {
    "index": {
      "number_of_shards": 2,  
      "number_of_replicas": 1 
    }
  }
}'
{"acknowledged":true,"shards_acknowledged":true,"index":"ind-2"}

# curl -H 'Content-Type: application/json'  -X PUT localhost:9200/ind-3 -d'
{
  "settings": {
    "index": {
      "number_of_shards": 4,  
      "number_of_replicas": 2 
    }
  }
}'
{"acknowledged":true,"shards_acknowledged":true,"index":"ind-3"}
```


Получите список индексов и их статусов, используя API и **приведите в ответе** на задание.

```bash
# curl -X GET 'http://localhost:9200/_cat/indices?v'
health status index uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   ind-1 0Zdrgkd0Rpyxm_CNZIimKA   1   0          0            0       225b           225b
yellow open   ind-3 qSyj_X8hQNiASoIhs6fV3Q   4   2          0            0       900b           900b
yellow open   ind-2 zIRm7gxrSS6Fjl2BctOXgA   2   1          0            0       450b           450b

```

Получите состояние кластера `elasticsearch`, используя API.

```bash
# curl localhost:9200/_cluster/health | python3 -m json.tool
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   411  100   411    0     0  68500      0 --:--:-- --:--:-- --:--:-- 82200
{
    "cluster_name": "netology_test_cluster",
    "status": "yellow",
    "timed_out": false,
    "number_of_nodes": 1,
    "number_of_data_nodes": 1,
    "active_primary_shards": 8,
    "active_shards": 8,
    "relocating_shards": 0,
    "initializing_shards": 0,
    "unassigned_shards": 10,
    "delayed_unassigned_shards": 0,
    "number_of_pending_tasks": 0,
    "number_of_in_flight_fetch": 0,
    "task_max_waiting_in_queue_millis": 0,
    "active_shards_percent_as_number": 44.44444444444444
}
```

Как вы думаете, почему часть индексов и кластер находится в состоянии yellow?  

Поскольку кластер состоит из одной ноды, шарды индексов ind-2 и ind-3 не реплицированы и находятся в статусе unssigned. После добавления дополнительных нод в кластер на которые они смогут реплицироваться статус их изменится на GREEN, кластер так же сменит статус после репликации.

Удалите все индексы.

```bash
# curl -X DELETE localhost:9200/ind-1
{"acknowledged":true}

# curl -X DELETE "localhost:9200/ind-2?pretty"
{
  "acknowledged" : true
}

# curl -X DELETE "localhost:9200/ind-3?pretty"
{
  "acknowledged" : true
}

```

**Важно**

При проектировании кластера elasticsearch нужно корректно рассчитывать количество реплик и шард,
иначе возможна потеря данных индексов, вплоть до полной, при деградации системы.

## Задача 3

В данном задании вы научитесь:
- создавать бэкапы данных
- восстанавливать индексы из бэкапов

Создайте директорию `{путь до корневой директории с elasticsearch в образе}/snapshots`.

Используя API [зарегистрируйте](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-register-repository.html#snapshots-register-repository) 
данную директорию как `snapshot repository` c именем `netology_backup`.

**Приведите в ответе** запрос API и результат вызова API для создания репозитория.

```bash
curl -X PUT "localhost:9200/_snapshot/netology_backup?pretty" -H 'Content-Type: application/json' -d'
{
  "type": "fs",
  "settings": {
    "location": "/var/lib/elasticsearch/snapshots",
    "compress": true
  }
}'
{
  "acknowledged" : true
}

```

Проверка:  
```bash
# curl -XGET 'http://localhost:9200/_snapshot/_all?pretty'
{
  "netology_backup" : {
    "type" : "fs",
    "settings" : {
      "compress" : "true",
      "location" : "/var/lib/elasticsearch/snapshots"
    }
  }
}

```

Создайте индекс `test` с 0 реплик и 1 шардом и **приведите в ответе** список индексов.

```bash
# curl -H 'Content-Type: application/json'  -X PUT localhost:9200/test -d'
{
  "settings": {
    "index": {
      "number_of_shards": 1,  
      "number_of_replicas": 0 
    }
  }
}'
{"acknowledged":true,"shards_acknowledged":true,"index":"test"}

Список индексов:  

# curl -X GET 'http://localhost:9200/_cat/indices?v'
health status index uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   test  P_pov1ZmR7ec_knINwtW-w   1   0          0            0       225b           225b

```

[Создайте `snapshot`](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-take-snapshot.html) 
состояния кластера `elasticsearch`.

Создвние снэпшота:  
```bash
# curl  -H 'Content-Type: application/json'   -X PUT 'http://localhost:9200/_snapshot/netology_backup/snapshot_20220618?wait_for_completion=true&pretty'
{
  "snapshot" : {
    "snapshot" : "snapshot_20220618",
    "uuid" : "1RKHKQp_SFmkHZzXSNE0CA",
    "repository" : "netology_backup",
    "version_id" : 8000199,
    "version" : "8.0.1",
    "indices" : [
      "test",
      ".geoip_databases"
    ],
    "data_streams" : [ ],
    "include_global_state" : true,
    "state" : "SUCCESS",
    "start_time" : "2022-06-18T17:44:20.707Z",
    "start_time_in_millis" : 1655574260707,
    "end_time" : "2022-06-18T17:44:21.708Z",
    "end_time_in_millis" : 1655574261708,
    "duration_in_millis" : 1001,
    "failures" : [ ],
    "shards" : {
      "total" : 2,
      "failed" : 0,
      "successful" : 2
    },
    "feature_states" : [
      {
        "feature_name" : "geoip",
        "indices" : [
          ".geoip_databases"
        ]
      }
    ]
  }
}

```

**Приведите в ответе** список файлов в директории со `snapshot`ами.

```bash
# docker exec nicko-elasticsearch-docker ls -l /var/lib/elasticsearch/snapshots/
total 32
-rw-r--r-- 1 elastic elastic   850 Jun 18 17:44 index-0
-rw-r--r-- 1 elastic elastic     8 Jun 18 17:44 index.latest
drwxr-xr-x 4 elastic elastic  4096 Jun 18 17:44 indices
-rw-r--r-- 1 elastic elastic 15481 Jun 18 17:44 meta-1RKHKQp_SFmkHZzXSNE0CA.dat
-rw-r--r-- 1 elastic elastic   362 Jun 18 17:44 snap-1RKHKQp_SFmkHZzXSNE0CA.dat
```

Удалите индекс `test` и создайте индекс `test-2`. **Приведите в ответе** список индексов.


Удаляю:  
```bash
# curl -X DELETE "localhost:9200/test?pretty"
{
  "acknowledged" : true
}
```

Создаю индекс test-2:  
```bash
# curl -H 'Content-Type: application/json'  -X PUT localhost:9200/test-2 -d'
{
  "settings": {
    "index": {
      "number_of_shards": 1,  
      "number_of_replicas": 0 
    }
  }
}'
{"acknowledged":true,"shards_acknowledged":true,"index":"test-2"}
```

Список индексов:  
```bash
# curl -k -X GET 'http://localhost:9200/_cat/indices?v'
health status index  uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   test-2 rMYDGAFMSiGZwwAnhNlTlA   1   0          0            0       225b           225b

```

[Восстановите](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-restore-snapshot.html) состояние
кластера `elasticsearch` из `snapshot`, созданного ранее. 

**Приведите в ответе** запрос к API восстановления и итоговый список индексов.

Восстанавливаю:  
```bash
# curl  -H 'Content-Type: application/json'   -X POST 'http://localhost:9200/_snapshot/netology_backup/snapshot_20220618/_restore?pretty'
{
  "accepted" : true
}
```

Список индексов после восстановления:  
```bash
# curl -k -X GET 'http://localhost:9200/_cat/indices?v'
health status index  uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   test-2 rMYDGAFMSiGZwwAnhNlTlA   1   0          0            0       225b           225b
green  open   test   MUYllEJPRN-N9mJNQQWWFg   1   0          0            0       225b           225b
```

Подсказки:
- возможно вам понадобится доработать `elasticsearch.yml` в части директивы `path.repo` и перезапустить `elasticsearch`

---

### Как cдавать задание

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
