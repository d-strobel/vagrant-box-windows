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
variable "release" {
  description = "Define the semver release. E.g. '0.1.0'."
  type        = string
}
variable "vagrant_token" {
  description = "Define the Vagrant Cloud access token."
  type        = string
  sensitive   = true
}
variable "vagrant_box_tag" {
  description = "Define the Vagrant box tag. E.g. 'win2022'."
  type        = string
}
