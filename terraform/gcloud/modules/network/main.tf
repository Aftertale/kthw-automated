resource "google_compute_network" "this" {
  name                    = "kubernetes"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "this" {
  name          = "kubernetes"
  ip_cidr_range = "10.240.0.0/24"
  network       = google_compute_network.this.id
}

resource "google_compute_firewall" "allow_int" {
  name    = "kubernetes-allow-internal"
  network = google_compute_network.this.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  source_ranges = ["10.240.0.0/24", "10.200.0.0/16"]
}

resource "google_compute_firewall" "allow_ext" {
  name    = "kubernetes-allow-external"
  network = google_compute_network.this.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "6443"]
  }

  source_ranges = ["0.0.0.0/0"]
}
