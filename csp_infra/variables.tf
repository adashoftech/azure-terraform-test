variable "hub_cidr" {
  default = "10.28.215.0/25"
  type = string
}

variable "hub_subnet" {
  default = {
    a = "10.28.215.0/26"
    b = "10.28.215.64/26"
  }
}

variable "spoke_cidr" {
  default = "10.28.215.128/25"
}

variable "spoke_subnet" {
  default = {
    a = "10.28.215.128/26"
    b = "10.28.215.192/26"
  }
}

variable "rg_location" {
  default     = "eastus"
  description = "Location of the resource group."
}
