/*
  Windows Packer => Vagrant build
*/

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
    ansible = {
      version = "1.1.0"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

locals {
  // VM Ressources
  disk_size_gb = 40
  memory_gb    = 2
  cpus         = 2

  // Get version number from version.txt
  version = file("version.txt")

  // Outputs
  output_dir = "output-windows"
  box_output = format("%s/%s.box", local.output_dir, var.vm_name)
}

// Virtualbox
source "virtualbox-iso" "windows" {

  vm_name              = var.vm_name
  iso_url              = var.iso_url
  iso_checksum         = var.iso_checksum
  disk_size            = local.disk_size_gb * 1024
  boot_wait            = "5s"
  guest_os_type        = var.guest_os_type
  guest_additions_mode = "disable"

  floppy_files = [
    format("files/%s/Autounattend.xml", var.build),
    "scripts/ConfigureRemotingForAnsible.ps1",
    "scripts/InstallVirtualboxGuestAdditions.ps1"
  ]

  vboxmanage = [
    ["modifyvm", "{{.Name}}", "--memory", "${local.memory_gb * 1024}"],
    ["modifyvm", "{{.Name}}", "--cpus", "${local.cpus}"],
  ]

  communicator     = "winrm"
  winrm_username   = "Administrator"
  winrm_password   = "vagrant"
  winrm_insecure   = true
  winrm_use_ssl    = true
  shutdown_command = "shutdown /s /t 5 /f /d p:4:1 /c \"Packer Shutdown\""
  shutdown_timeout = "15m"
}

// Build process
build {
  sources = ["source.virtualbox-iso.windows"]

  provisioner "powershell" {
    scripts = ["scripts/Setup.ps1"]
  }

  provisioner "windows-restart" {
    restart_timeout = "15m"
  }

  provisioner "powershell" {
    scripts = ["scripts/SetupActiveDirectory.yml"]
  }

  provisioner "windows-restart" {
    restart_timeout = "15m"
  }

  provisioner "windows-update" {
    pause_before = "30s"
  }

  provisioner "windows-restart" {
    restart_timeout = "15m"
  }

  post-processors {
    post-processor "artifice" {
      files = [
        format("%s/%s-disk001.vmdk", local.output_dir, var.vm_name),
        format("%s/%s.ovf", local.output_dir, var.vm_name)
      ]
    }

    post-processor "vagrant" {
      output               = local.box_output
      keep_input_artifact  = false
      provider_override    = "virtualbox"
      vagrantfile_template = format("files/%s/Vagrantfile.template", var.build)
    }

    post-processor "vagrant-cloud" {
      box_tag             = format("d-strobel/%s", var.vagrant_box_tag)
      architecture        = "amd64"
      version             = local.version
      version_description = format("Changelog: https://github.com/d-strobel/vagrant-box-windows/releases/tag/v%s", local.version)
      keep_input_artifact = true
    }
  }
}
