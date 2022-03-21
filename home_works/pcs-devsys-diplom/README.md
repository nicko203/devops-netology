## Курсовая работа по итогам модуля "DevOps и системное администрирование"

### 1. Создайте виртуальную машину Linux.  

### 2. Установите ufw и разрешите к этой машине сессии на порты 22 и 443, при этом трафик на интерфейсе localhost (lo) должен ходить свободно на все порты.  

Последовательность команд для установки и настройки ufw:  

```apt install ufw  
ufw allow 22  
ufw allow 443  
ufw disable  
ufw enable
```  


Результат настройки:  

![ufw_status](ufw_status.png)  


### 3. Установите hashicorp vault ( https://learn.hashicorp.com/tutorials/vault/getting-started-install?in=vault/getting-started#install-vault ).  

Доступ к репозиторию закрыт. Через VPN выкачал бинарник для своей платформы.  

*_vault -v_*
```
Vault v1.9.4 (fcbe948b2542a13ee8036ad07dd8ebf8554f56cb)
```

### 4. Cоздайте центр сертификации по инструкции ( https://learn.hashicorp.com/tutorials/vault/pki-engine?in=vault/secrets-management ) и выпустите сертификат для использования его в настройке веб-сервера nginx (срок жизни сертификата - месяц).  

Запускаю в дополнительном терминале  vault-сервер:  
```
vault server -dev -dev-root-token-id root
```

Экспортирую переменные окружения:  
```
export VAULT_ADDR=http://127.0.0.1:8200
export VAULT_TOKEN=root
```  

*__Генерирую корневой сертификат:__*  

1. Включаю механизм pki-секретов по пути  pki:

```
vault secrets enable pki
```

2. Настраиваю  механизм pki secrets engine на выдачу сертификатов с максимальным временем работы (TTL) один месяц ( 720 часов):  
```
vault secrets tune -max-lease-ttl=720h pki
```  


3. Создаю корневой сертификат и сохраняю  его в файле CA_cert.crt:  
```
vault write -field=certificate pki/root/generate/internal common_name="test.ru" ttl=720h > CA_cert.crt
```  

4. Настраиваю URL-адреса CA и CRL:
```
vault write pki/config/urls issuing_certificates="$VAULT_ADDR/v1/pki/ca" crl_distribution_points="$VAULT_ADDR/v1/pki/crl"
```  


**_Генерирую промежуточный сертификат:_**  

1. Включаю механизм pki секретов по пути pki_int:  
```
vault secrets enable -path=pki_int pki
```  

2. Настраиваю механизм pki_int секретов на выдачу сертификатов с максимальным временем работы (TTL) один месяц ( 720 часов ):  
```
vault secrets tune -max-lease-ttl=720h pki_int
```  

3. Генерирую промежуточный сертификат  и сохраняю запрос CSR как pki_intermediate.csr:  
```
vault write -format=json pki_int/intermediate/generate/internal common_name="test.ru Intermediate Authority" | jq -r '.data.csr' > pki_intermediate.csr
```  

4. Подписываю промежуточный сертификат закрытым ключом корневого центра сертификации и сохраняю сгенерированный сертификат как intermediate.cert.pem:  
```
vault write -format=json pki/root/sign-intermediate csr=@pki_intermediate.csr format=pem_bundle ttl="720h" | jq -r '.data.certificate' > intermediate.cert.pem
```  

5. Как только CSR будет подписан и корневой центр сертификации вернет сертификат, его можно будет импортировать обратно в Хранилище:  
```
vault write pki_int/intermediate/set-signed certificate=@intermediate.cert.pem
```  

**_Создаю роль:_**  
```
vault write pki_int/roles/test-dot-ru  allowed_domains="test.ru" allow_subdomains=true  max_ttl="720h"
```

**_Создание сертификата:_**  
```
vault write pki_int/issue/test-dot-ru common_name="test.ru" ttl="720h"
```  

