#!/usr/bin/env python3

import os
import socket
import json
import yaml

jsonDefaultServices  = {"drive.google.com": "0.0.0.0", "mail.google.com": "0.0.0.0", "google.com": "0.0.0.0"}

jServicesFile = "services.json"
yServicesFile = "services.yaml"

if os.path.isfile(jServicesFile):
    with open(jServicesFile) as json_data_file:
        jsonDefaultServices = json.load(json_data_file)

for host, ip in jsonDefaultServices.items():
    new_ip=socket.gethostbyname(host)

    if (ip != new_ip):
        print ('[ERROR] {} IP mismatch: {} {}'.format(host,ip,new_ip))
        jsonDefaultServices[host]=new_ip

for host, ip in jsonDefaultServices.items():
    print('{} - {}'.format(host,ip))

with open(jServicesFile, "w") as json_data_file:
    json.dump(jsonDefaultServices, json_data_file, indent=2)

with open(yServicesFile, "w") as y_data:
    y_data.write(yaml.dump(jsonDefaultServices,explicit_start=True, explicit_end=True))