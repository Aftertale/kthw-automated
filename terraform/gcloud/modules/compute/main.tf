# Not in the kthw instructions, but Google recommends assigning a service account to a compute instance
# so we create them here and attach them
resource "google_service_account" "controller" {
  count        = var.num_controllers
  account_id   = "k8s-controller${count.index}"
  display_name = "Service Account"
}

resource "google_compute_instance" "controllers" {
  count        = var.num_controllers
  name         = "controller-${count.index}"
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

    network_ip = "10.240.0.1${count.index}"
  }

  service_account {
    email  = google_service_account.controller[count.index].email
    scopes = ["compute-rw", "storage-ro", "service-management", "service-control", "logging-write", "monitoring"]
  }
}

resource "google_service_account" "worker" {
  count        = var.num_workers
  account_id   = "k8s-worker${count.index}"
  display_name = "Service Account"
}

resource "google_compute_instance" "workers" {
  count        = var.num_workers
  name         = "worker-${count.index}"
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

    network_ip = "10.240.0.2${count.index}"
  }

  service_account {
    email  = google_service_account.worker[count.index].email
    scopes = ["compute-rw", "storage-ro", "service-management", "service-control", "logging-write", "monitoring"]
  }

  metadata = {
    pod-cidr = "10.200.${count.index}.0/24"
  }
}
