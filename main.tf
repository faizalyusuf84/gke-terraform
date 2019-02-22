terraform {
  required_version = ">= 0.11.0"
  backend "gcs" {
  	credentials = "${var.credentials_file_path}"
    bucket  = "terraform-state99"
    prefix  = "terraform/state/"
  }
}

#provider "vault" {
#  address = "${var.vault_addr}"
#}

#data "vault_generic_secret" "gcp_credentials" {
#  path = "secret/${var.vault_user}/gcp/credentials"
#}

#resource "vault_auth_backend" "k8s" {
#  type = "kubernetes"
#  path = "${var.vault_user}-gke-${var.environment}"
#  description = "Vault Auth backend for Kubernetes"
#}

provider "google" {
  credentials = "${var.credentials_file_path}"
  project     = "${var.gcp_project}"
  region      = "${var.gcp_region}"
}

resource "google_container_cluster" "k8sexample" {
  name               = "${var.cluster_name}"
  description        = "example k8s cluster"
  zone               = "${var.gcp_zone}"
  initial_node_count = "${var.initial_node_count}"
  enable_kubernetes_alpha = "true"
  enable_legacy_abac = "true"

  master_auth {
    username = "${var.master_username}"
    password = "${var.master_password}"
  }

  node_config {
    machine_type = "${var.node_machine_type}"
    disk_size_gb = "${var.node_disk_size}"
    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring"
    ]
  }
}

#resource "null_resource" "auth_config" {
#  provisioner "local-exec" {
#    command = "curl --header \"X-Vault-Token: $VAULT_TOKEN\" --header \"Content-Type: application/json\" --request POST --data '{ \"kubernetes_host\": \"https://${google_container_cluster.k8sexample.endpoint}:443\", \"kubernetes_ca_cert\": \"${chomp(replace(base64decode(google_container_cluster.k8sexample.master_auth.0.cluster_ca_certificate), "\n", "\\n"))}\" }' ${var.vault_addr}/v1/auth/${vault_auth_backend.k8s.path}config"
#  }
#}

#resource "vault_generic_secret" "role" {
#  path = "auth/${vault_auth_backend.k8s.path}role/demo"
#  data_json = <<EOT
#  {
#    "bound_service_account_names": "cats-and-dogs",
#    "bound_service_account_namespaces": "default",
#    "policies": "${var.vault_user}",
#    "ttl": "24h"
#  }
#  EOT
#}

#resource "google_sql_database_instance" "master" {
#  name = "master-instance"
#  database_version = "MYSQL_5_6"
  # First-generation instance regions are not the conventional
  # Google Compute Engine regions. See argument reference below.
#  region = "${var.gcp_region}"

#  settings {
#    tier = "db-f1-micro"
#  }
#}

#resource "google_compute_global_address" "default" {
#  name = "webapp-static-ip"
#}