# Windows Server Vagrant boxes

Build and deploy Windows Vagrant boxes with Hashicorp Packer.


## Prerequisites
* Hashicorp packer installed
* Virtualbox installed
* To upload to Vagrant Cloud, the environment variable 'VAGRANT_CLOUD_TOKEN' must be set

## Usage
To build all windows machines run the following commands:

```bash
make packer-init
make packer-validate
make packer-build
```

## Release
To release a new version use the release-please bot.
Afterwards pull the main branch and run the packer build (see 'Usage').

## Inspirations
- https://github.com/ruzickap/packer-templates
- https://github.com/eaksel/packer-Win2019
- https://github.com/gusztavvargadr/
