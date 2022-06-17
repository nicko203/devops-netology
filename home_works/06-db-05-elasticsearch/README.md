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

Получите список индексов и их статусов, используя API и **приведите в ответе** на задание.

Получите состояние кластера `elasticsearch`, используя API.

Как вы думаете, почему часть индексов и кластер находится в состоянии yellow?

Удалите все индексы.

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

Создайте индекс `test` с 0 реплик и 1 шардом и **приведите в ответе** список индексов.

[Создайте `snapshot`](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-take-snapshot.html) 
состояния кластера `elasticsearch`.

**Приведите в ответе** список файлов в директории со `snapshot`ами.

Удалите индекс `test` и создайте индекс `test-2`. **Приведите в ответе** список индексов.

[Восстановите](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-restore-snapshot.html) состояние
кластера `elasticsearch` из `snapshot`, созданного ранее. 

**Приведите в ответе** запрос к API восстановления и итоговый список индексов.

Подсказки:
- возможно вам понадобится доработать `elasticsearch.yml` в части директивы `path.repo` и перезапустить `elasticsearch`

---

### Как cдавать задание

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
