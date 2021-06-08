terraform {
  required_providers {
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "3.70.0"
    }
  }
}

provider "google" {
  project = "djm-kubernetes-thw"
  region  = "us-west1"
  zone    = "us-west1-c"
}

module "network" {
  source = "./modules/network"
}

module "compute" {
  source          = "./modules/compute"
  subnet          = module.network.subnet
}
