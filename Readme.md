# Terraform Installation and Setup Guide

Follow these steps to install and set up Terraform on your Windows machine.

## Step 1: Download the Terraform Installer

1. Navigate to the [Terraform installation page](https://developer.hashicorp.com/terraform/install?product_intent=terraform).
2. Choose the **Windows AMD64** installer from the list of available download options.

## Step 2: Extract and Place the Terraform Executable

1. Extract the downloaded `.zip` file.
2. Copy `terraform.exe` to your desired folder (e.g., `C:\Terraform`).

## Step 3: Set the Environment Variable Path

1. Right-click on **This PC** or **Computer** and select **Properties**.
2. Click on **Advanced system settings** and then **Environment Variables**.
3. Under **System variables**, find and select **Path**, then click **Edit**.
4. Click **New** and add the path to the folder where `terraform.exe` is located (e.g., `C:\Terraform`).
5. Click **OK** to save the changes.

## Step 4: Verify the Installation

Open a new Command Prompt or terminal and run the following command to check if Terraform is installed:

```sh
terraform -v
```

If installed correctly, the version of Terraform should be displayed.

## Step 5: Install the Terraform Extension in VS Code

1. Open **Visual Studio Code (VS Code)**.
2. Go to the **Extensions** view by clicking on the Extensions icon or pressing `Ctrl + Shift + X`.
3. Search for **"Terraform"** and install the official extension.

## Step 6: Initialize Terraform

Navigate to your project directory and run:

```sh
terraform init
```

This command downloads all necessary plugins and APIs required for your provider (e.g., AWS).

## Step 7: Dry run Terraform changes

```sh
terraform plan
terraform apply --auto-approve
```

## Step 7: Clean up resources created by Terraform

```sh
terraform destroy
```

## Show output

```sh
terraform state list
terraform state show aws_vpc.my-first-vpc
terraform output
terraform refresh
```

## Delete/Create a specific resource

```sh
terraform destroy -target aws_instance.web-server-instance
terraform apply -target aws_instance.web-server-instance
```

## Provide variable value using cmd line

```sh
terraform apply -var "subnet_prefix=10.0.100.0/24"
```

If var file named other than "terraform.tfvars" use the following command:

```sh
terraform apply -var-file example.tfvars
```

## Others

Three fields can be given to a value block

1. description
2. default
3. type

If working with var of type list, use:

```sh
var.subnet_prefix[0]
```

Within each region, AWS has multiple data centres, so if one data centre goes down, the region doesn't go down (redundancy).
availability zone = data centre?

Route Table - connects subnets to gateways

1. Associate subnet to route table
2. Specify CIDR block that can access a gateway

Network interface - attach EC2 instance in a subnet

For you to have a public IP address via Elastic IP, your VPC/subnet needs to have an Internet Gateway

Need to wait for 2/2 checks to pass, only then user-data is fully executed

- .terraform folder is created when we initialize any plugins
- terraform.tfstate keeps track of all resources created
