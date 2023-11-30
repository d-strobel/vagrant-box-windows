/*
  Windows Server 2022 Standard Core
    + Active-Directory
    + DHCP Server
    + DFS
*/

// Virtualbox
source "virtualbox-iso" "win2022sc-ad" {

  vm_name              = "win2022sc-ad"
  iso_url              = "https://software-static.download.prss.microsoft.com/sg/download/888969d5-f34g-4e03-ac9d-1f9786c66749/SERVER_EVAL_x64FRE_en-us.iso"
  iso_checksum         = "sha256:3e4fa6d8507b554856fc9ca6079cc402df11a8b79344871669f0251535255325"
  disk_size            = 40 * 1024
  boot_wait            = "5s"
  guest_os_type        = "Windows2022_64"
  guest_additions_mode = "disable"

  floppy_files = [
    "files/win2022sc-ad/Autounattend.xml",
    "scripts/InstallVirtualboxGuestAdditions.ps1",
    "scripts/SetupOpenSSH.ps1",
    "scripts/ConfigureRemotingForAnsible.ps1"
  ]

  vboxmanage = [
    ["modifyvm", "{{.Name}}", "--memory", "${2 * 1024}"],
    ["modifyvm", "{{.Name}}", "--cpus", "2"],
  ]

  communicator     = "winrm"
  winrm_username   = "vagrant"
  winrm_password   = "vagrant"
  winrm_insecure   = true
  winrm_use_ssl    = true
  shutdown_command = "shutdown /s /t 5 /f /d p:4:1 /c \"packer shutdown\""
  shutdown_timeout = "15m"
}

// Build process
build {
  name    = "win2022sc-ad"
  sources = ["source.virtualbox-iso.win2022sc-ad"]

  provisioner "powershell" {
    scripts      = ["scripts/SetupSystem.ps1", ]
    pause_before = "30s"
  }

  provisioner "windows-restart" {
    restart_timeout = "15m"
  }

  provisioner "powershell" {
    scripts = [
      "scripts/SetupActiveDirectory.ps1",
      "scripts/SetupDHCP.ps1",
      "scripts/SetupDFS.ps1",
    ]
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
        format("output-%s/%s-disk001.vmdk", build.name, build.name),
        format("output-%s/%s.ovf", build.name, build.name)
      ]
    }

    post-processor "vagrant" {
      output               = format("output-%s/%s.box", build.name, build.name)
      keep_input_artifact  = false
      provider_override    = "virtualbox"
      vagrantfile_template = format("files/%s/Vagrantfile.template", build.name)
    }

    post-processor "vagrant-cloud" {
      box_tag             = format("d-strobel/%s", build.name)
      architecture        = "amd64"
      version             = local.version
      version_description = format("Changelog: https://github.com/d-strobel/vagrant-box-windows/releases/tag/v%s", local.version)
      keep_input_artifact = false
    }
  }
}
