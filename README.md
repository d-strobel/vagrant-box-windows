# Windows Server Vagrant boxes

Build and deploy Windows Vagrant boxes with Hashicorp Packer.

## Version
| Windows Server         | Version |
| ---------------------- | ----- |
| Windows Server 2022 Standard Core | 2022-sc |

## Usage (example)

```bash
make packer-init
make packer-validate VERSION=2022-sc
make packer-build VERSION=2022-sc
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_guest_os_type"></a> [guest\_os\_type](#input\_guest\_os\_type) | Define the VM guest os type. | `string` | n/a | yes |
| <a name="input_iso_checksum"></a> [iso\_checksum](#input\_iso\_checksum) | Define the checksum for the windows iso in the format 'type:checksum'. | `string` | n/a | yes |
| <a name="input_iso_url"></a> [iso\_url](#input\_iso\_url) | Define the URL for windows iso download. | `string` | n/a | yes |
| <a name="input_version"></a> [version](#input\_version) | Define the build version. E.g '2022-sc'. | `string` | n/a | yes |
| <a name="input_vm_name"></a> [vm\_name](#input\_vm\_name) | Define the name of the Virtual Machine and Vagrant box. | `string` | n/a | yes |

## Inspirations
- https://github.com/ruzickap/packer-templates
- https://github.com/eaksel/packer-Win2019
- https://github.com/gusztavvargadr/
