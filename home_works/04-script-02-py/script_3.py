#!/usr/bin/env python3

import os

print("Введите полный путь к репозиторию:")
sRepPath = input()

bash_command = ["cd "+sRepPath, "git status"]
result_os = os.popen(' && '.join(bash_command)).read()

print("\n")

is_change = False
for result in result_os.split('\n'):
    if result.find('изменено:') != -1:
        prepare_result = result.replace('\tизменено:   ', '').strip()
        print(sRepPath+prepare_result)

print("\n")
