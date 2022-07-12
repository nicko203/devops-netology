resource "yandex_iam_service_account" "s3" {
  folder_id = "${var.yandex_folder_id}"
  name      = "s3-nicko2003"
}

resource "yandex_resourcemanager_folder_iam_member" "sa-editor" {
  folder_id = "${var.yandex_folder_id}"
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.s3.id}"
}

resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.s3.id
  description        = "Static access key for object storage"
}

resource "yandex_storage_bucket" "state-nicko2003" {
  bucket     = "tf-state-bucket-test-nicko2003"
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
}