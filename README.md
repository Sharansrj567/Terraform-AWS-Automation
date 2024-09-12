# Terraform AWS Automation

This project automates the provisioning of AWS infrastructure using Terraform. It includes modules for creating a VPC, subnets, and web servers.

## Project Structure

```
.
├── .gitignore
├── .terraform.lock.hcl
├── main.tf
├── modules/
│   ├── subnet/
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   └── webserver/
│       ├── entry-script.sh
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
├── outputs.tf
├── providers.tf
├── README.md
├── terraform.tfvars.dist
└── variables.tf
```

This is the directory structure of the project. It includes the main Terraform files, modules for subnet and webserver, as well as other configuration files and directories.

Please let me know if there's anything else I can help you with.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) installed on your machine.
- AWS credentials configured on your machine.

## Configuration

1. **Providers**: The AWS provider is configured in providers.tf.

    ```hcl
    provider "aws" {
      region = "eu-central-1"
    }
    ```

2. **Variables**: Define your variables in variables.tf.

    ```hcl
    variable "vpc_cidr_block" {}
    variable "subnet_cidr_block" {}
    variable "avail_zone" {}
    variable "env_prefix" {}
    variable "my_ip" {}
    variable "instance_type" {}
    variable "public_key_location" {}
    variable "private_key_location" {}
    ```

3. **Main Configuration**: The main Terraform configuration is in main.tf.

    ```hcl
    terraform {
      required_providers {
        aws = {
          source = "hashicorp/aws"
          version = "5.6.2"
        }
      }
    }

    resource "aws_vpc" "myapp-vpc" {
      cidr_block = var.vpc_cidr_block
      tags = {
        Name: "${var.env_prefix}-vpc"
      }
    }

    module "myapp-subnet" {
      source = "./modules/subnet"
      avail_zone = var.avail_zone
      env_prefix = var.env_prefix
      subnet_cidr_block = var.subnet_cidr_block
      vpc_id = aws_vpc.myapp-vpc.id
    }

    module "myapp-webserver" {
      source = "./modules/webserver"
      avail_zone = var.avail_zone
      env_prefix = var.env_prefix
      instance_type = var.instance_type
      my_ip = var.my_ip
      private_key_location = var.private_key_location
      public_key_location = var.public_key_location
      subnet_id = module.myapp-subnet.subnet.id
      vpc_id = aws_vpc.myapp-vpc.id
    }
    ```

4. **Outputs**: Define the outputs in outputs.tf.

    ```hcl
    output "aws_ami_id" {
      value = module.myapp-webserver.latest-amazon-linux-image.id
    }
    output "ec2_public_ip" {
      value = module.myapp-webserver.server-public-ip
    }
    ```

## Usage

1. **Initialize Terraform**:

    ```sh
    terraform init
    ```

2. **Plan the Infrastructure**:

    ```sh
    terraform plan
    ```

3. **Apply the Configuration**:

    ```sh
    terraform apply
    ```

4. **Destroy the Infrastructure**:

    ```sh
    terraform destroy
    ```

## Modules

### Subnet Module

Located in modules/subnet.

- **Variables**: Defined in variables.tf.
- **Outputs**: Defined in outputs.tf.

### Webserver Module

Located in modules/webserver.

- **Variables**: Defined in variables.tf.
- **Outputs**: Defined in outputs.tf.
- **Entry Script**: entry-script.sh.

## License

This project is licensed under the MIT License.