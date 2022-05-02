# AWS Cloud Computing

## Description
Project related to aws cloud computing bootcamp.

## Requirements
- [terraform](https://www.terraform.io/downloads.html) 
- An account in AWS.

## Terraform
In the folder to the repositorie we need to run the command:

``` ssh
terraform init
```
The above command will initialize the modules and the backend.

If this is the first time you are uploading the environment, it is important to run the command:

``` ssh
terraforming plan
```
It will show the execution plan with all the settings chosen in the ```main.tf``` file. So if all the settings are correct just run the command

 ``` ssh
terraform apply
 ```

If the environment is running on AWS and you want to see its settings, just run the command:

``` ssh
show terraform
```

## Inputs

|Name|Description|Type|Default|Optional|
|:-:|:-:|:-:|:-:|:-:|
|cdirs_remote_access|"List of CIDR blocks|string|--|No|
|region|Region of the instance|string|us-east-1|Yes|
|amis|AMI to use for the instance|map|ami-026c8acd92718196b|Yes|
|instance_type|Type of the instance|string|t2-micro|Yes|
|port|Number of the port to security group|number|22|Yes|

## Output

```
# IP list of instances
output "instance_ip" {
  value = [for instance in aws_instance.dev.*.public_i: {group = instance}]
}
```
