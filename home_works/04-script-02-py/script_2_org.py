#!/usr/bin/env python3

import os

#bash_command = ["cd ~/netology/sysadm-homeworks", "git status"]
bash_command = ["cd ~/EDU/NETOLOGY/DevOps/devops-netology/home_works", "git status"]
result_os = os.popen(' && '.join(bash_command)).read()
is_change = False
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        print(prepare_result)
        break