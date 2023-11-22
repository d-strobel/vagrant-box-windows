/*
    Packer build variables
*/

variable "vm_name" {
  description = "Define the name of the Virtual Machine and Vagrant box."
  type        = string
}
variable "iso_url" {
  description = "Define the URL for windows iso download."
  type        = string
}
variable "iso_checksum" {
  description = "Define the checksum for the windows iso in the format 'type:checksum'."
  type        = string
}
variable "guest_os_type" {
  description = "Define the VM guest os type."
  type        = string
}
variable "version" {
  description = "Define the build version. E.g '2022-sc'."
  type        = string
}
