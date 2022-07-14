terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"


  backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "tf-state-bucket-test-nicko2003"
    region     = "ru-central1-a"
    key        = "terraform/infrastructure1/terraform.tfstate"
    access_key = "YCA...NBd"
    secret_key = "YCP...4pS"

#Load from keys.tf
#    access_key = "${var.yandex_cloud_s3_access_key}"
#    secret_key = "${var.yandex_cloud_s3_secret_key}"

 
    skip_region_validation      = true
    skip_credentials_validation = true
  }

}

provider "yandex" {
  #  token     = "<OAuth>"  Load from environment var YC_TOKEN

# Load from variables.tf
  cloud_id  = "${var.yandex_cloud_id}"
  folder_id = "${var.yandex_folder_id}"

  zone      = "ru-central1-a"
}

