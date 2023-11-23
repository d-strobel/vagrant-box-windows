/*
  Windows Packer => Vagrant build
*/

packer {
  required_plugins {
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
  // VM Ressources
  disk_size_gb = 40
  memory_gb    = 2
  cpus         = 2

  // Output
  output_dir = format("%s/output-windows", abspath(path.root))
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
    format("%s/files/%s/Autounattend.xml", abspath(path.root), var.version),
    format("%s/scripts/ConfigureRemotingForAnsible.ps1", abspath(path.root)),
    format("%s/scripts/InstallVirtualboxGuestAdditions.ps1", abspath(path.root))
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
      output              = local.box_output
      keep_input_artifact = false
      provider_override   = "virtualbox"
    }

    post-processor "vagrant-cloud" {
      access_token = var.vagrant_token
      box_tag      = format("d-strobel/%s", var.vagrant_box_tag)
      architecture = "amd64"
      version      = var.release
    }
  }
}
