provider "aws" {
  region = "us-east-1" 
  profile = "terraform-user"
}

## AWS API to read/retrieve all AZs in this region via using Data Source Block 
# "aws_avilability_zones" ==> is mandaotry to be written in this format
# "available" ==> can be anything 

data "aws_availability_zones" "available" {
  
}

## Configure Basic VPC ##

#### Basic Main VPC have EC2 instance  and endpoint which connect to 
##### API Gateway has own  VPC because it is SERVERLESS + Lambda Function has own VPC as well  so we dont have control on these vpcs
resource "aws_vpc" "main" {
  enable_dns_hostnames                 = var.enable_dns_hostnames
  enable_dns_support                   = var.enable_dns_support
  cidr_block       = var.vpc_cidr
  tags = {
    Name = var.vpc_name   
  }
}




##### Create AZ, Private-Subnet  via cirdrsubnet with format function  ####

data "aws_availability_zones" "with" {
}


resource "aws_internet_gateway" "IGW" {
   vpc_id = aws_vpc.main.id

  tags = {
     Name = "IGW"
  }
 }

 resource "aws_route_table" "ec2_route_table" {
   vpc_id = aws_vpc.main.id

   route {
     cidr_block = "0.0.0.0/0"
     gateway_id = aws_internet_gateway.IGW.id
   }

  tags = {
    Name = "EC2_route_Table"
   }
 }
resource "aws_subnet" "EC2_subnets_for_main_vpc" {
count = var.max_subnets


vpc_id = aws_vpc.main.id
cidr_block = cidrsubnet(var.vpc_cidr,var.in_subnet_cidr_size,count.index)
availability_zone = element(data.aws_availability_zones.with.names,count.index)

tags = {
  Name = "EC2_subnet_main_vpc  ${format("%02d", count.index + 1)}"
}

}


# # Associate the Route Table with the Subnets
resource "aws_route_table_association" "EC2_subnet_association" {
  count              = var.max_subnets  # Create associations for each subnet
  subnet_id          = aws_subnet.EC2_subnets_for_main_vpc[count.index].id  # Reference the subnet by count.index
  route_table_id     = aws_route_table.ec2_route_table.id  # Reference the route table
 }





## create AWS VPC Interface Endpoint to connect to API GW VPC privatly from Lambda in main VPC 

resource "aws_vpc_endpoint" "main_vpc_interface_endpoint" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.us-east-1.execute-api"  # API Gateway service"
  vpc_endpoint_type = "Interface"
  subnet_ids = [aws_subnet.EC2_subnets_for_main_vpc[0].id] # Specify the subnet(s) here
 tags = {
    Name = "API Interface VPC Endpoint"
  }
}

### Declare key pair and save it using local file in same folder of terraform 
resource "tls_private_key" "key001" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "python01" {
  key_name   = "ec2-lambda-key-pair"
  public_key = tls_private_key.key001.public_key_openssh  # Use the generated public key
}
resource "local_file" "private_key" {
  filename = "${path.module}/my-key-pair01.pem"
  content  = tls_private_key.key001.private_key_pem
}


### create ubuntu ec2 in main vpc with python installation ##

data "aws_ami" "ubuntu" {


 filter {
    name   = "image-id"
    values = ["ami-04b4f1a9cf54c11d0"]  # Replace with the actual AMI ID
  }

  owners = ["099720109477"]  # Canonical's AWS account ID
}

resource "aws_instance" "python" {
  ami           = data.aws_ami.ubuntu.id
  associate_public_ip_address = true ## in order to b accessed 
  # Associate the exist key pair with the EC2 instance
  key_name = aws_key_pair.python01.key_name 
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.EC2_subnets_for_main_vpc[1].id
  # User Data script to install and deploy the Python package
  user_data = <<-EOF
              #!/bin/bash
              # Update the instance and install dependencies
              sudo apt-get update -y
              sudo apt-get install -y python3 python3-pip
              sudo  apt-get update -y
              sudo apt install pipx
              pipx install requests
                    
              EOF

  tags = {
    Name = "PythonAppInstance"
  }
}

##Security Group / API GW AND Lambda function will be provisioned via  AWS Console
# we will configure simple-request.py  OR use curl from EC2 TO API GW