# Create Amazon Machine Image (AMI) using Packer with R1Soft server pre-installed 

Packer is an open source tool for creating identical machine images for multiple platforms from a single source configuration. 

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
| files/r1softagent.repo | Contains repository information  |


### Quick Start

After Packer is installed, create your first template, which tells Packer what platforms to build images for and how you want to build them. In our case, we'll create a simple AMI that has R1soft pre-installed. Save this file as r1soft.json. 
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
        "region": "{{user `region`}}",
        "ssh_username": "centos",
        "ssh_keypair_name": "london-bastion",
        "ssh_private_key_file": "~/.ssh/id_rsa",
        "ami_name": "r1soft-example {{timestamp}}"
      }
    ],
 ```

Provisioners are responsible for installing and configuring software on the running machines prior to turning them into machine images. Packer provides in-built support for different kinds of provisioners mainly Shell, File, Poweshell, Ansible, Chef and Puppet etc.

 "provisioners": [
 
      {
      "type": "file",
      "source": "../files/r1soft.repo",
      "destination": "/tmp/"
         },
        
        { 
          "type": "shell",
          "inline":[
            "sudo curl -O https://inspector-agent.amazonaws.com/linux/latest/install",
            "sudo bash install https://docs.aws.amazon.com/inspector/latest/userguide/inspector_installing-uninstalling-agents.html", 
            "sudo yum install epel-release -y",
            "sudo yum install python-pip -y",
            "sudo mv  /tmp/r1soft.repo  /etc/yum.repos.d/",
            "sudo mv /etc/yum.repos.d/Cen* /tmp/",
            "sudo yum install r1soft-cdp-enterprise-server -y"
  
          ]},

          {
            "type": "breakpoint",
            "note": "Wait for you to delete"
              },

           {
          "type": "shell",
          "inline":[
            "sudo r1soft-setup --http-port 8080",
            "sudo /etc/init.d/cdp-server restart"
          ]
          
           }
       ]
  }
 
### Create AMI 

Run below command to create AMI
```sh
$ packer validate r1soft.json
```
You should see validation output
```sh
Template validated successfully.
```

Run below command to create AMI

```sh
$ packer build r1soft.json
```

This will create a new EC2 instanace based on the source_ami, does the software provisioning, stops the instance, creates an AMI based on new instance and then terminates the EC2 instance.
