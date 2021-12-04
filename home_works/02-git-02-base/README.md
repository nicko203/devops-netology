Задание №1 – Знакомимся с gitlab и bitbucket

- созданы аккаунты на https://gitlab.com/  и https://bitbucket.org/ ;
- созданы публичные репозитории;
- добавлены дополнительные репозитории:
    - git remote add gitlab https://gitlab.com/nicko203/devops-netology.git
    - git remote add bitbucket https://nicko203@bitbucket.org/nicko203/devops-netology.git
- Вывод git remote -v:

bitbucket	https://nicko203@bitbucket.org/nicko203/devops-netology.git (fetch)
bitbucket	https://nicko203@bitbucket.org/nicko203/devops-netology.git (push)
gitlab	https://gitlab.com/nicko203/devops-netology.git (fetch)
gitlab	https://gitlab.com/nicko203/devops-netology.git (push)
origin	https://github.com/nicko203/devops-netology.git (fetch)
origin	https://github.com/nicko203/devops-netology.git (push)

- "запушен" локальный репозитория на серверы:
    - git push gitlab
    - git push bitbucket
    - git push origin


