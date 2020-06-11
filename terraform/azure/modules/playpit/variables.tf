variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  default = "playpit"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  default = "uksouth"
}

variable "vm_size" {
  description = "VM Size"
  default = "Standard_B2s"  
}


variable "full_name" {
  description = "User Name"
  # default = "Siarhei Beliakou"
}

variable "username" {
  description = "System's username"
  # default = "sbeliakou"
}

variable "training" {
  description = "Training Name: docker or kubernetes"
  # default = "docker"
}
