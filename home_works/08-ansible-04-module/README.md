# Домашнее задание к занятию "08.04 Создание собственных modules"

## Подготовка к выполнению
1. Создайте пустой публичных репозиторий в любом своём проекте: `my_own_collection`
2. Скачайте репозиторий ansible: `git clone https://github.com/ansible/ansible.git` по любому удобному вам пути
3. Зайдите в директорию ansible: `cd ansible`
4. Создайте виртуальное окружение: `python3 -m venv venv`
5. Активируйте виртуальное окружение: `. venv/bin/activate`. Дальнейшие действия производятся только в виртуальном окружении
6. Установите зависимости `pip install -r requirements.txt`
7. Запустить настройку окружения `. hacking/env-setup`
8. Если все шаги прошли успешно - выйти из виртуального окружения `deactivate`
9. Ваше окружение настроено, для того чтобы запустить его, нужно находиться в директории `ansible` и выполнить конструкцию `. venv/bin/activate && . hacking/env-setup`

## Основная часть

Наша цель - написать собственный module, который мы можем использовать в своей role, через playbook. Всё это должно быть собрано в виде collection и отправлено в наш репозиторий.

1. В виртуальном окружении создать новый `my_own_module.py` файл
```
cd lib/ansible/modules/
(venv) root@3c:~/ansible_practice/ansible/lib/ansible/modules# touch ./my_own_module.py
```
2. Наполнить его содержимым:
```python
#!/usr/bin/python

# Copyright: (c) 2018, Terry Jones <terry.jones@example.org>
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)
from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r'''
---
module: my_test

short_description: This is my test module

# If this is part of a collection, you need to use semantic versioning,
# i.e. the version is of the form "2.5.0" and not "2.4".
version_added: "1.0.0"

description: This is my longer description explaining my test module.

options:
    name:
        description: This is the message to send to the test module.
        required: true
        type: str
    new:
        description:
            - Control to demo if the result of this module is changed or not.
            - Parameter description can be a list as well.
        required: false
        type: bool
# Specify this value according to your collection
# in format of namespace.collection.doc_fragment_name
extends_documentation_fragment:
    - my_namespace.my_collection.my_doc_fragment_name

author:
    - Your Name (@yourGitHubHandle)
'''

EXAMPLES = r'''
# Pass in a message
- name: Test with a message
  my_namespace.my_collection.my_test:
    name: hello world

# pass in a message and have changed true
- name: Test with a message and changed output
  my_namespace.my_collection.my_test:
    name: hello world
    new: true

# fail the module
- name: Test failure of the module
  my_namespace.my_collection.my_test:
    name: fail me
'''

RETURN = r'''
# These are examples of possible return values, and in general should use other names for return values.
original_message:
    description: The original name param that was passed in.
    type: str
    returned: always
    sample: 'hello world'
message:
    description: The output message that the test module generates.
    type: str
    returned: always
    sample: 'goodbye'
'''

from ansible.module_utils.basic import AnsibleModule


def run_module():
    # define available arguments/parameters a user can pass to the module
    module_args = dict(
        name=dict(type='str', required=True),
        new=dict(type='bool', required=False, default=False)
    )

    # seed the result dict in the object
    # we primarily care about changed and state
    # changed is if this module effectively modified the target
    # state will include any data that you want your module to pass back
    # for consumption, for example, in a subsequent task
    result = dict(
        changed=False,
        original_message='',
        message=''
    )

    # the AnsibleModule object will be our abstraction working with Ansible
    # this includes instantiation, a couple of common attr would be the
    # args/params passed to the execution, as well as if the module
    # supports check mode
    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=True
    )

    # if the user is working with this module in only check mode we do not
    # want to make any changes to the environment, just return the current
    # state with no modifications
    if module.check_mode:
        module.exit_json(**result)

    # manipulate or modify the state as needed (this is going to be the
    # part where your module will do what it needs to do)
    result['original_message'] = module.params['name']
    result['message'] = 'goodbye'

    # use whatever logic you need to determine whether or not this module
    # made any modifications to your target
    if module.params['new']:
        result['changed'] = True

    # during the execution of the module, if there is an exception or a
    # conditional state that effectively causes a failure, run
    # AnsibleModule.fail_json() to pass in the message and the result
    if module.params['name'] == 'fail me':
        module.fail_json(msg='You requested this to fail', **result)

    # in the event of a successful module execution, you will want to
    # simple AnsibleModule.exit_json(), passing the key/value results
    module.exit_json(**result)


def main():
    run_module()


if __name__ == '__main__':
    main()
```
Или возьмите данное наполнение из [статьи](https://docs.ansible.com/ansible/latest/dev_guide/developing_modules_general.html#creating-a-module).

3. Заполните файл в соответствии с требованиями ansible так, чтобы он выполнял основную задачу: module должен создавать текстовый файл на удалённом хосте по пути, определённом в параметре `path`, с содержимым, определённым в параметре `content`.
4. Проверьте module на исполняемость локально.

- Добавил файл args.json:  
```
{
    "ANSIBLE_MODULE_ARGS": {
        "path": "/tmp/test_01.txt",
        "content": "Hello, netology!"
    }
}
```

```
(venv) root@3c:~/ansible_practice/ansible# python -m ansible.modules.my_own_module args.json

{"changed": false, "original_message": "Hello, netology!", "message": "file exists", "invocation": {"module_args": {"path": "/tmp/test_01.txt", "content": "Hello, netology!"}}}

```

- Проверяю содержимое:  
```
(venv) root@3c:~/ansible_practice/ansible# cat /tmp/test_01.txt
Hello, netology!
```

5. Напишите single task playbook и используйте module в нём.  

- site.yml

```
---
- name: Test my_own_module
  hosts: localhost
  gather_facts: false
  tasks:
    - name: Execute module
      my_own_module:
        path: "/tmp/test_03.txt"
        content: "Test module in task\nHello, netology!\n"
```

```
# ansible-playbook site.yml
[WARNING]: You are running the development version of Ansible. You should only run Ansible from "devel" if you are modifying the Ansible engine, or trying out features under development.
This is a rapidly changing source of code and can become unstable at any point.

PLAY [Test my_own_module] ********************************************************************************************************************************************************************

TASK [Execute module] ************************************************************************************************************************************************************************
changed: [localhost]

PLAY RECAP ***********************************************************************************************************************************************************************************
localhost                  : ok=1    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

```

6. Проверьте через playbook на идемпотентность.

```
# ansible-playbook site.yml
[WARNING]: You are running the development version of Ansible. You should only run Ansible from "devel" if you are modifying the Ansible engine, or trying out features under development.
This is a rapidly changing source of code and can become unstable at any point.

PLAY [Test my_own_module] ********************************************************************************************************************************************************************

TASK [Execute module] ************************************************************************************************************************************************************************
ok: [localhost]

PLAY RECAP ***********************************************************************************************************************************************************************************
localhost                  : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```
7. Выйдите из виртуального окружения.
8. Инициализируйте новую collection: `ansible-galaxy collection init my_own_namespace.my_own_collection`
```
(venv) root@3c:~/ansible_practice/ansible# ansible-galaxy collection init my_own_namespace.my_own_collection
[WARNING]: You are running the development version of Ansible. You should only run Ansible from "devel" if you are modifying the Ansible engine, or trying out features under development.
This is a rapidly changing source of code and can become unstable at any point.
- Collection my_own_namespace.my_own_collection was created successfully
```

9. В данную collection перенесите свой module в соответствующую директорию.

10. Single task playbook преобразуйте в single task role и перенесите в collection. У role должны быть default всех параметров module
11. Создайте playbook для использования этой role.
```
(venv) root@3c:~/ansible_practice/ansible/my_own_namespace/my_own_collection/roles# ansible-galaxy role init my_role
[WARNING]: You are running the development version of Ansible. You should only run Ansible from "devel" if you are modifying the Ansible engine, or trying out features under development.
This is a rapidly changing source of code and can become unstable at any point.
- Role my_role was created successfully
```
- defaults/main.yml:
```
---
test_path: "/tmp/test_remote_01.txt"
test_content: "Test module in task\nHello, netology!\n"
```
- tasks/main.yml:
```
---
# tasks file for my_role
- name: Execute module
  my_own_module:
    path: "{{ test_path }}"
    content: "{{ test_content }}"
```
- inventory/server.yml:
```
debian:
  hosts:
    nginx_debian:
      ansible_host: 10.36.77.24
centos:
  hosts:
    nginx_centos:
      ansible_host: 10.36.77.27
```

- playbook site1.yml
```
---
- name: Test my_own_module in docker
  hosts:
    - debian
  roles:
    - my_role
```

- запуск playbook:
```
(venv) root@3c:~/ansible_practice/ansible/my_own_namespace/my_own_collection# ansible-playbook -i inventory/server.yml site1.yml
[WARNING]: You are running the development version of Ansible. You should only run Ansible from "devel" if you are modifying the Ansible engine, or trying out features under development.
This is a rapidly changing source of code and can become unstable at any point.

PLAY [Test my_own_module in docker] **********************************************************************************************************************************************************

TASK [Gathering Facts] ***********************************************************************************************************************************************************************
ok: [nginx_debian]

TASK [my_role : Execute module] **************************************************************************************************************************************************************
changed: [nginx_debian]

PLAY RECAP ***********************************************************************************************************************************************************************************
nginx_debian               : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

```

- проверка на идемпотентность:
```
(venv) root@3c:~/ansible_practice/ansible/my_own_namespace/my_own_collection# ansible-playbook -i inventory/server.yml site1.yml
[WARNING]: You are running the development version of Ansible. You should only run Ansible from "devel" if you are modifying the Ansible engine, or trying out features under development.
This is a rapidly changing source of code and can become unstable at any point.

PLAY [Test my_own_module in docker] **********************************************************************************************************************************************************

TASK [Gathering Facts] ***********************************************************************************************************************************************************************
ok: [nginx_debian]

TASK [my_role : Execute module] **************************************************************************************************************************************************************
ok: [nginx_debian]

PLAY RECAP ***********************************************************************************************************************************************************************************
nginx_debian               : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

```

12. Заполните всю документацию по collection, выложите в свой репозиторий, поставьте тег `1.0.0` на этот коммит.

13. Создайте .tar.gz этой collection: `ansible-galaxy collection build` в корневой директории collection.
```
(venv) root@3c:~/ansible_practice/ansible/my_own_namespace/my_own_collection# ansible-galaxy collection build
[WARNING]: You are running the development version of Ansible. You should only run Ansible from "devel" if you are modifying the Ansible engine, or trying out features under development.
This is a rapidly changing source of code and can become unstable at any point.
Created collection for my_own_namespace.my_own_collection at /root/ansible_practice/ansible/my_own_namespace/my_own_collection/my_own_namespace-my_own_collection-1.0.0.tar.gz

```
14. Создайте ещё одну директорию любого наименования, перенесите туда single task playbook и архив c collection.
15. Установите collection из локального архива: `ansible-galaxy collection install <archivename>.tar.gz`
```
(venv) root@3c:~/ansible_practice/ansible/my_collection# ansible-galaxy collection install my_own_namespace-my_own_collection-1.0.0.tar.gz -p collections
[WARNING]: You are running the development version of Ansible. You should only run Ansible from "devel" if you are modifying the Ansible engine, or trying out features under development.
This is a rapidly changing source of code and can become unstable at any point.
Starting galaxy collection install process
[WARNING]: The specified collections path '/root/ansible_practice/ansible/my_collection/collections' is not part of the configured Ansible collections paths
'/root/.ansible/collections:/usr/share/ansible/collections'. The installed collection will not be picked up in an Ansible run, unless within a playbook-adjacent collections directory.
Process install dependency map
Starting collection install process
Installing 'my_own_namespace.my_own_collection:1.0.0' to '/root/ansible_practice/ansible/my_collection/collections/ansible_collections/my_own_namespace/my_own_collection'
my_own_namespace.my_own_collection:1.0.0 was installed successfully

```
16. Запустите playbook, убедитесь, что он работает.

- playbook `site.yml`:
```
---
- name: Test my_own_module
  hosts: localhost
  gather_facts: false
  tasks:
    - name: Execute module
      my_own_namespace.my_own_collection.my_own_module:
        path: "/tmp/test_02.txt"
        content: "Test module in task\nHello, netology!\n"
```

```
(venv) root@3c:~/ansible_practice/ansible/my_collection# ansible-playbook -i inventory/server.yml site.yml
[WARNING]: You are running the development version of Ansible. You should only run Ansible from "devel" if you are modifying the Ansible engine, or trying out features under development.
This is a rapidly changing source of code and can become unstable at any point.

PLAY [Test my_own_module] ********************************************************************************************************************************************************************

TASK [Execute module] ************************************************************************************************************************************************************************
ok: [localhost]

PLAY RECAP ***********************************************************************************************************************************************************************************
localhost                  : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   


```

17. В ответ необходимо прислать ссылку на репозиторий с collection

[Ссылка](https://github.com/nicko203/my_own_collection)  на репозиторий с коллекцией.


## Необязательная часть

1. Используйте свой полёт фантазии: Создайте свой собственный module для тех roles, что мы делали в рамках предыдущих лекций.
2. Соберите из roles и module отдельную collection.
3. Создайте новый репозиторий и выложите новую collection туда.

Если идей нет, но очень хочется попробовать что-то реализовать: реализовать module восстановления из backup elasticsearch.


---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
