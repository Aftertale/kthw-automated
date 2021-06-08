# Not in the kthw instructions, but Google recommends assigning a service account to a compute instance
# so we create them here and attach them
resource "google_service_account" "controller" {
  count        = length(var.controllers)
  account_id   = "k8s-controller${count.index}"
  display_name = "Service Account"
}

resource "google_compute_address" "external" {
  name = "kubernetes-the-hard-way"
}

resource "google_compute_instance" "controllers" {
  for_each = toset(var.controllers)
  name         = each.key
  machine_type = "e2-standard-2"

  tags = ["k8s", "controller"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
      size  = 200
    }
  }

  can_ip_forward = true

  network_interface {
    subnetwork = var.subnet.id

    network_ip = "10.240.0.1${index(var.controllers, each.value)}"
  }

  service_account {
    email  = google_service_account.controller[index(var.controllers, each.value)].email
    scopes = ["compute-rw", "storage-ro", "service-management", "service-control", "logging-write", "monitoring"]
  }
}

resource "google_service_account" "worker" {
  count        = length(var.workers)
  account_id   = "k8s-worker${count.index}"
  display_name = "Service Account"
}

resource "google_compute_instance" "workers" {
  for_each = toset(var.workers)
  name         = each.key 
  machine_type = "e2-standard-2"

  tags = ["k8s", "worker"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
      size  = 200
    }
  }

  can_ip_forward = true

  network_interface {
    subnetwork = var.subnet.id

    network_ip = "10.240.0.2${index(var.workers, each.value)}"
  }

  service_account {
    email  = google_service_account.worker[index(var.workers, each.value)].email
    scopes = ["compute-rw", "storage-ro", "service-management", "service-control", "logging-write", "monitoring"]
  }

  metadata = {
    pod-cidr = "10.200.${index(var.workers, each.value)}.0/24"
  }
}
