variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  default = "playpit"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  default = "northeurope"
}

variable "vm_size" {
  description = "VM Size"
  default = "Standard_B2s"  
}

variable "fullname" {
  description = "User Name"
}

variable "shortname" {
  description = "System's username"
}

variable "training" {
  description = "Training Name: docker or kubernetes"
}
