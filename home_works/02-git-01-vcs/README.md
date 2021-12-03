## Домашнее задание к занятию "2.1. Системы контроля версий."

Игнорируемые файлы — это файлы, которые не должны попадать в коммиты. 

Игнорируемые файлы отслеживаются в файле .gitignore, находящимся в каталоге terraform репозитория. 

Будут игнорироваться:
- все файлы содержащиеся в каталогах /.terraform/ в любом месте дерева;
- все файлы .tfstate с расширением и без;
- файлы crash.log;
- файлы с расширением tfvars (*.tfvars);
- файлы override.tf и override.tf.json;
- файлы по шаблону *_override.tf и *_override.tf.json;
- файлы .terraformrc и terraform.rc
