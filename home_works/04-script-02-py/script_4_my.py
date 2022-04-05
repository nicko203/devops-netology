#!/usr/bin/env python3

import os
import socket
import json

jsonDefaultServices  = {"drive.google.com": "0.0.0.0", "mail.google.com": "0.0.0.0", "google.com": "0.0.0.0"}

sServicesFile = "services.json"

if os.path.isfile(sServicesFile):
    with open(sServicesFile) as json_data_file:
        jsonDefaultServices = json.load(json_data_file)

for host, ip in jsonDefaultServices.items():
    new_ip=socket.gethostbyname(host)

    if (ip != new_ip):
        print ('[ERROR] {} IP mismatch: {} {}'.format(host,ip,new_ip))
        jsonDefaultServices[host]=new_ip

for host, ip in jsonDefaultServices.items():
    print('{} - {}'.format(host,ip))

with open(sServicesFile, "w") as json_data_file:
    json.dump(jsonDefaultServices, json_data_file, indent=2)