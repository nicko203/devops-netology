# for_count
resource "yandex_compute_instance" "vm-01" {
  count = var.instance_count[terraform.workspace]
  name  = "nicko2003-vm-01-${terraform.workspace}-number-${count.index+1}"
  allow_stopping_for_update = true

  lifecycle {
    create_before_destroy = true
  }

  resources {
    cores = var.cores_cnt[terraform.workspace]
    memory = var.memory_cnt[terraform.workspace]
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


# for_each
resource "yandex_compute_instance" "vm-02" {
#  for_each = var.vms
  for_each = "${terraform.workspace == "prod" ? var.vms_prod : var.vms_stage}"
  name  = "nicko2003-vm-02-${each.value.name}"

  allow_stopping_for_update = true

  lifecycle {
    create_before_destroy = true
  }

  resources {
    cores         = each.value.cores
    memory        = each.value.memory_size
  }

  boot_disk {
    initialize_params {
      image_id = "fd81u2vhv3mc49l1ccbb"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-2.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}


resource "yandex_vpc_network" "network-1" {
  name = "network1-${terraform.workspace}"
}
resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1-${terraform.workspace}"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}


resource "yandex_vpc_network" "network-2" {
  name = "network2-${terraform.workspace}"
}
resource "yandex_vpc_subnet" "subnet-2" {
  name           = "subnet2-${terraform.workspace}"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-2.id
  v4_cidr_blocks = ["192.168.20.0/24"]
}

