#!/usr/bin/env python3

import os

sRepPath = "~/EDU/NETOLOGY/DevOps/devops-netology/home_works/"

bash_command = ["cd "+sRepPath, "git status"]
result_os = os.popen(' && '.join(bash_command)).read()

print("\n")

for result in result_os.split('\n'):
    if result.find('изменено:') != -1:
        prepare_result = result.replace('\tизменено:   ', '').strip()
        print(sRepPath+prepare_result)

print("\n")
