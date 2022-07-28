# Домашнее задание к занятию "08.02 Работа с Playbook"

## Подготовка к выполнению
1. Создайте свой собственный (или используйте старый) публичный репозиторий на github с произвольным именем.
2. Скачайте [playbook](./playbook/) из репозитория с домашним заданием и перенесите его в свой репозиторий.
3. Подготовьте хосты в соотвтествии с группами из предподготовленного playbook. 

4. Скачайте дистрибутив [java](https://www.oracle.com/java/technologies/javase-jdk11-downloads.html) и положите его в директорию `playbook/files/`. 

## Основная часть
1. Приготовьте свой собственный inventory файл `prod.yml`.  
Решение:  
```
---
all:
  hosts:
    ubuntu:
      ansible_connection: docker
elasticsearch:
  hosts:
    ubuntu:
      ansible_connection: docker
kibana:
  hosts:
    ubuntu:
      ansible_connection: docker
```  

2. Допишите playbook: нужно сделать ещё один play, который устанавливает и настраивает kibana.
Решение:  
[playbook](./playbook/site.yml)
3. При создании tasks рекомендую использовать модули: `get_url`, `template`, `unarchive`, `file`.
4. Tasks должны: скачать нужной версии дистрибутив, выполнить распаковку в выбранную директорию, сгенерировать конфигурацию с параметрами.
5. Запустите `ansible-lint site.yml` и исправьте ошибки, если они есть.
```
# ansible-lint site.yml
WARNING  Listing 7 violation(s) that are fatal
[208] File permissions unset or incorrect
site.yml:9
Task/Handler: Upload .tar.gz file containing binaries from local storage

[208] File permissions unset or incorrect
site.yml:16
Task/Handler: Ensure installation dir exists

[208] File permissions unset or incorrect
site.yml:32
Task/Handler: Export environment variables

[208] File permissions unset or incorrect
site.yml:51
Task/Handler: Create directrory for Elasticsearch

[208] File permissions unset or incorrect
site.yml:66
Task/Handler: Set environment Elastic

[208] File permissions unset or incorrect
site.yml:86
Task/Handler: Create directrory for Kibana

[208] File permissions unset or incorrect
site.yml:101
Task/Handler: Set environment Kibana

You can skip specific rules or tags by adding them to your configuration file:                                                                                                                

┌────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│ # .ansible-lint                                                                                                                                                                            │
│ warn_list:  # or 'skip_list' to silence them completely                                                                                                                                    │
│   - '208'  # File permissions unset or incorrect                                                                                                                                           │
│   - experimental  # all rules tagged as experimental                                                                                                                                       │
└────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

Для исправления ошибок устанавливаю права `0644` для файлов(архивов) и `0755` для каталогов и скриптов.  

6. Попробуйте запустить playbook на этом окружении с флагом `--check`.  

```
# docker run --name ubuntu -d pycontribs/ubuntu sleep 36000000
```

Проверка не проходит:  
```
# ansible-playbook -i inventory/prod.yml site.yml --check

PLAY [Install Java] **************************************************************************************************************************************************************************

TASK [Gathering Facts] ***********************************************************************************************************************************************************************
ok: [ubuntu]

TASK [Set facts for Java 11 vars] ************************************************************************************************************************************************************
ok: [ubuntu]

TASK [Upload .tar.gz file containing binaries from local storage] ****************************************************************************************************************************
changed: [ubuntu]

TASK [Ensure installation dir exists] ********************************************************************************************************************************************************
changed: [ubuntu]

TASK [Extract java in the installation directory] ********************************************************************************************************************************************
fatal: [ubuntu]: FAILED! => {"changed": false, "msg": "dest '/opt/jdk/11.0.16' must be an existing dir"}

PLAY RECAP ***********************************************************************************************************************************************************************************
ubuntu                     : ok=4    changed=2    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0   


```

7. Запустите playbook на `prod.yml` окружении с флагом `--diff`. Убедитесь, что изменения на системе произведены.

```
# ansible-playbook -i inventory/prod.yml site.yml --diff

PLAY [Install Java] **************************************************************************************************************************************************************************

TASK [Gathering Facts] ***********************************************************************************************************************************************************************
ok: [ubuntu]

TASK [Set facts for Java 11 vars] ************************************************************************************************************************************************************
ok: [ubuntu]

TASK [Upload .tar.gz file containing binaries from local storage] ****************************************************************************************************************************
diff skipped: source file size is greater than 104448
changed: [ubuntu]

TASK [Ensure installation dir exists] ********************************************************************************************************************************************************
--- before
+++ after
@@ -1,4 +1,4 @@
 {
     "path": "/opt/jdk/11.0.16",
-    "state": "absent"
+    "state": "directory"
 }

changed: [ubuntu]

TASK [Extract java in the installation directory] ********************************************************************************************************************************************
changed: [ubuntu]

TASK [Export environment variables] **********************************************************************************************************************************************************
--- before
+++ after: /root/.ansible/tmp/ansible-local-212109yicpq85z/tmpvqbs0uzk/jdk.sh.j2
@@ -0,0 +1,5 @@
+# Warning: This file is Ansible Managed, manual changes will be overwritten on next playbook run.
+#!/usr/bin/env bash
+
+export JAVA_HOME=/opt/jdk/11.0.16
+export PATH=$PATH:$JAVA_HOME/bin
\ No newline at end of file

changed: [ubuntu]

PLAY [Install Elasticsearch] *****************************************************************************************************************************************************************

TASK [Gathering Facts] ***********************************************************************************************************************************************************************
ok: [ubuntu]

TASK [Upload tar.gz Elasticsearch from remote URL] *******************************************************************************************************************************************
changed: [ubuntu]

TASK [Create directrory for Elasticsearch] ***************************************************************************************************************************************************
--- before
+++ after
@@ -1,4 +1,4 @@
 {
     "path": "/opt/elastic/8.3.2",
-    "state": "absent"
+    "state": "directory"
 }

changed: [ubuntu]

TASK [Extract Elasticsearch in the installation directory] ***********************************************************************************************************************************
changed: [ubuntu]

TASK [Set environment Elastic] ***************************************************************************************************************************************************************
--- before
+++ after: /root/.ansible/tmp/ansible-local-212109yicpq85z/tmpr5pii2f2/elk.sh.j2
@@ -0,0 +1,5 @@
+# Warning: This file is Ansible Managed, manual changes will be overwritten on next playbook run.
+#!/usr/bin/env bash
+
+export ES_HOME=/opt/elastic/8.3.2
+export PATH=$PATH:$ES_HOME/bin
\ No newline at end of file

changed: [ubuntu]

PLAY [Install Kibana] ************************************************************************************************************************************************************************

TASK [Upload tar.gz Kibana from remote URL] **************************************************************************************************************************************************
changed: [ubuntu]

TASK [Create directrory for Kibana] **********************************************************************************************************************************************************
--- before
+++ after
@@ -1,4 +1,4 @@
 {
     "path": "/opt/kibana/8.3.2",
-    "state": "absent"
+    "state": "directory"
 }

changed: [ubuntu]

TASK [Extract Kibana in the installation directory] ******************************************************************************************************************************************
changed: [ubuntu]

TASK [Set environment Kibana] ****************************************************************************************************************************************************************
--- before
+++ after: /root/.ansible/tmp/ansible-local-212109yicpq85z/tmpgsv0spqq/kibana.sh.j2
@@ -0,0 +1,5 @@
+# Warning: This file is Ansible Managed, manual changes will be overwritten on next playbook run.
+#!/usr/bin/env bash
+
+export KIBANA_HOME=/opt/kibana/8.3.2
+export PATH=$PATH:$KIBANA_HOME/bin
\ No newline at end of file

changed: [ubuntu]

PLAY RECAP ***********************************************************************************************************************************************************************************
ubuntu                     : ok=15   changed=12   unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

```
8. Повторно запустите playbook с флагом `--diff` и убедитесь, что playbook идемпотентен.
```
# ansible-playbook -i inventory/prod.yml site.yml --diff

PLAY [Install Java] **************************************************************************************************************************************************************************

TASK [Gathering Facts] ***********************************************************************************************************************************************************************
ok: [ubuntu]

TASK [Set facts for Java 11 vars] ************************************************************************************************************************************************************
ok: [ubuntu]

TASK [Upload .tar.gz file containing binaries from local storage] ****************************************************************************************************************************
ok: [ubuntu]

TASK [Ensure installation dir exists] ********************************************************************************************************************************************************
ok: [ubuntu]

TASK [Extract java in the installation directory] ********************************************************************************************************************************************
skipping: [ubuntu]

TASK [Export environment variables] **********************************************************************************************************************************************************
ok: [ubuntu]

PLAY [Install Elasticsearch] *****************************************************************************************************************************************************************

TASK [Gathering Facts] ***********************************************************************************************************************************************************************
ok: [ubuntu]

TASK [Upload tar.gz Elasticsearch from remote URL] *******************************************************************************************************************************************
ok: [ubuntu]

TASK [Create directrory for Elasticsearch] ***************************************************************************************************************************************************
ok: [ubuntu]

TASK [Extract Elasticsearch in the installation directory] ***********************************************************************************************************************************
skipping: [ubuntu]

TASK [Set environment Elastic] ***************************************************************************************************************************************************************
ok: [ubuntu]

PLAY [Install Kibana] ************************************************************************************************************************************************************************

TASK [Upload tar.gz Kibana from remote URL] **************************************************************************************************************************************************
ok: [ubuntu]

TASK [Create directrory for Kibana] **********************************************************************************************************************************************************
ok: [ubuntu]

TASK [Extract Kibana in the installation directory] ******************************************************************************************************************************************
skipping: [ubuntu]

TASK [Set environment Kibana] ****************************************************************************************************************************************************************
ok: [ubuntu]

PLAY RECAP ***********************************************************************************************************************************************************************************
ubuntu                     : ok=12   changed=0    unreachable=0    failed=0    skipped=3    rescued=0    ignored=0   

```
9. Подготовьте README.md файл по своему playbook. В нём должно быть описано: что делает playbook, какие у него есть параметры и теги.  

Playbook

1. Устанавливает Java:  
- Определяет JAVA_HOME
- Загружает ранее скачанный архив с Java на сервер
- Создает директорию JAVA_HOME
- Распаковывает архив и создает дочерние к JAVA_HOME директории /bin/java
- Экспортирует переменные окружения из шаблона

2. Устанавливает Elasticsearch:  
- Скачивает архив Elasticsearch
- Создает директорию ELASTIC_HOME
- Распаковывает архив Elasticsearch
- Экспортирует переменные окружения из шаблона

3. Устанавливает Kibana:
- Скачивает архив Kibana
- Создает директорию KIBANA_HOME
- Распаковывает архив Kibana
- Экспортирует переменные окружения из шаблона
  
Параметры Playbook:  
- java_jdk_version
- java_oracle_jdk_package
- elastic_version
- elastic_home
- kibana_version
- kibana_home
  
Теги Playbook:  
- java
- elastic
- kibana

10. Готовый playbook выложите в свой репозиторий, в ответ предоставьте ссылку на него.
[playbook](./playbook/site.yml)

## Необязательная часть

1. Приготовьте дополнительный хост для установки logstash.
2. Пропишите данный хост в `prod.yml` в новую группу `logstash`.
3. Дополните playbook ещё одним play, который будет исполнять установку logstash только на выделенный для него хост.
4. Все переменные для нового play определите в отдельный файл `group_vars/logstash/vars.yml`.
5. Logstash конфиг должен конфигурироваться в части ссылки на elasticsearch (можно взять, например его IP из facts или определить через vars).
6. Дополните README.md, протестируйте playbook, выложите новую версию в github. В ответ предоставьте ссылку на репозиторий.

---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
