variable "location" {
  type        = string
  description = "Région ou localisation de déploiement"
  default     = "francecentral"
}

variable "prefix" {
  type        = string
  description = "Prefix used for Azure resource names"
  default     = "cloud1"
}

variable "vm_count" {
  type        = number
  description = "Number of Ubuntu VMs to provision"
  default     = 1
}

variable "vm_size" {
  type        = string
  description = "Azure VM size"
  default     = "Standard_B2s"
}

variable "admin_username" {
  type        = string
  description = "Admin SSH username on the VMs"
  default     = "azureuser"
}

variable "ssh_public_keys" {
  type        = set(string)
  description = "SSH public keys for both teammates"
}
