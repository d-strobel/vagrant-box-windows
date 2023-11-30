packer {
  required_plugins {
    virtualbox = {
      version = "1.0.5"
      source  = "github.com/hashicorp/virtualbox"
    }
    vagrant = {
      version = "1.1.0"
      source  = "github.com/hashicorp/vagrant"
    }
    windows-update = {
      version = "0.14.0"
      source  = "github.com/rgl/windows-update"
    }
  }
}

locals {
  // Get version number from version.txt
  version = file("version.txt")
}