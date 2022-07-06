terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  #  token     = "<OAuth>"
  cloud_id  = "b1gusbu5rl5peuirh6d4"
  folder_id = "b1giv01e8j41n6fkprqq"
  zone      = "ru-central1-a"
}


resource "yandex_compute_instance" "vm-01" {
  name = "nicko2003-vm-01"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd81u2vhv3mc49l1ccbb"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

output "internal_ip_address_vm_01" {
  value = yandex_compute_instance.vm-01.network_interface.0.ip_address
}

output "external_ip_address_vm_01" {
  value = yandex_compute_instance.vm-01.network_interface.0.nat_ip_address
}

