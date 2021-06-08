variable "subnet" {}

variable "workers" {
  type = list(string)
  default = ["worker-0", "worker-1", "worker-2"]
}

variable "controllers" {
  type = list(string)
  default = ["controller-0", "controller-1", "controller-2"]
}
