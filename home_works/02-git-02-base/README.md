## Задание №1 – Знакомимся с gitlab и bitbucket

- созданы аккаунты на https://gitlab.com/  и https://bitbucket.org/ ;
- созданы публичные репозитории;
- добавлены дополнительные репозитории:
    - git remote add gitlab https://gitlab.com/nicko203/devops-netology.git
    - git remote add bitbucket https://nicko203@bitbucket.org/nicko203/devops-netology.git
- Вывод git remote -v:

    - bitbucket	https://nicko203@bitbucket.org/nicko203/devops-netology.git (fetch)
    - bitbucket	https://nicko203@bitbucket.org/nicko203/devops-netology.git (push)
    - gitlab	https://gitlab.com/nicko203/devops-netology.git (fetch)
    - gitlab	https://gitlab.com/nicko203/devops-netology.git (push)
    - origin	https://github.com/nicko203/devops-netology.git (fetch)
    - origin	https://github.com/nicko203/devops-netology.git (push)

- "запушен" локальный репозиторий на серверы:
    - git push gitlab
    - git push bitbucket
    - git push origin


## Задание №2 – Теги

- создан легковестный тег v0.0;
- тег v0.0 запущен в три remote репозитория;
- создан аннотированный тег v0.1;
- тег v0.1 запущен в три remote репозитория.

