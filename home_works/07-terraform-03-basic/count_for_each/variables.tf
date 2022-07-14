# Заменить на ID своего облака
# https://console.cloud.yandex.ru/cloud?section=overview
variable "yandex_cloud_id" {
  default = "b1gusbu5rl5peuirh6d4"
}

# Заменить на Folder своего облака
# https://console.cloud.yandex.ru/cloud?section=overview
variable "yandex_folder_id" {
  default = "b1giv01e8j41n6fkprqq"
}

#count
variable "cores_cnt" {
  default = {
    prod  = 4
    stage = 2
  }
}

variable "memory_cnt" {
  default = {
    prod  = 4
    stage = 2
  }
}

variable "instance_count" {
  default = {
    stage = 1
    prod = 2
  }
}


# For_each
variable "vms" {
  description = "Map of VMS names to configuration"
  type        = map(any)
  default = {
    stage = {
      memory_size    = 2
      cores          = 2
      name           = "stage"
    },
    prod01 = {
      memory_size    = 4
      cores          = 4
      name           = "prod01"
    },
    prod02 = {
      memory_size    = 4
      cores          = 4
      name           = "prod02"
    }
  }
}

# For_each_v.2
variable "vms_prod" {
  description = "Map of VMS names to configuration for PROD workspace"
  type        = map(any)
  default = {
    prod01 = {
      memory_size    = 4
      cores          = 4
      name           = "prod01"
    },
    prod02 = {
      memory_size    = 4
      cores          = 4
      name           = "prod02"
    }
  }
}
variable "vms_stage" {
  description = "Map of VMS names to configuration for PROD workspace"
  type        = map(any)
  default = {
    stage = {
      memory_size    = 2
      cores          = 2
      name           = "stage"
    }
  }
}

