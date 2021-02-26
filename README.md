# Create Amazon Machine Image (AMI) using Packer

Packer is an open source tool for creating identical machine images for multiple platforms from a single source configuration. Packer is lightweight, runs on every major operating system, and is highly performant, creating machine images for multiple platforms in parallel. Packer does not replace configuration management like Chef or Puppet. In fact, when building images, Packer is able to use tools like Chef or Puppet to install software onto the image.

# Prerequisites

  - Packer is installed and you know what it does
  - You have an active AWS account (Free tier account is fine)
  - git is installed
  - Understand JSON file structure
  - Basics of bash command

# Getting Started
To install Packer run
```
wget https://releases.hashicorp.com/packer/1.5.1/packer_1.5.1_linux_amd64.zip
unzip packer_1.5.1_linux_amd64.zip
sudo mv packer /bin
```

Verify if Packer is installed
```
packer version
```

### File Structure

Read below section to understand the purpose of each file in this repo:

| FileName | Purpose |
| ------ | ------ |
| r1soft.json | A json file which is used by packer to build CentOS based AMI |
| files | Folder to keep provisioning bash script and dependencies for CentOS |
| files/userdata.sh | Bash script to povision softwares in image |


### Quick Start

After Packer is installed, create your first template, which tells Packer what platforms to build images for and how you want to build them. In our case, we'll create a simple AMI that has Wordpress web server pre-installed. 
```
{
    "builders": [
      {
        "type": "amazon-ebs",
        "source_ami_filter": {
            "filters": {
                "virtualization-type": "hvm",
                "name": "CentOS Linux 7 x86_64 HVM EBS ENA 1901_01-b7ee8a69-ee97-4a49-9e68-afaee216db2e-*",
                "root-device-type": "ebs"
                },
            "owners": ["679593333241"],
            "most_recent": true
            },
        "instance_type": "t2.micro",
        "ssh_username": "centos",
        "region": "us-east-1",
        "ami_name": "wordpress-example {{timestamp}}"
      }
    ],
 ```

Provisioners are responsible for installing and configuring software on the running machines prior to turning them into machine images. Packer provides in-built support for different kinds of provisioners mainly Shell, File, Poweshell, Ansible, Chef and Puppet etc.

          "provisioners": [
          {
         "type": "shell",
            "script": "../files/userdata.sh"        
            },
        {
          "type": "breakpoint",
          "note": "Wait for you to delete"
            }
         ]
    }

### Create Wordpress AMI 

Run below command to create Wordpress AMI
```sh
$ packer validate wordpress.json
```
You should see validation output
```sh
Template validated successfully.
```

Run below command to create Wordpress AMI

```sh
$ packer build wordpress.json
```

This will create a new EC2 instanace based on the source_ami, does the software provisioning, stops the instance, creates an AMI based on new instance and then terminates the EC2 instance.
