################ This the demo terraform file to create an EC2,RDS,S3 bucket and so on... #########

### Configure the AWS Provider
provider "aws" {
  region     = "ap-south-1"
}
####### Creation of VPC:
resource "aws_vpc" "myvpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "dev-vpc"
  }
}
## Creating a public subnet:
resource "aws_subnet" "public-subnet" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "public"
  }
}

### Creating of private subnet:
resource "aws_subnet" "private-subnet" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "private"
  }
}

### aws internet gateway creation:
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "internetgw"
  }
}

### Creating public route table to connect the internet:
resource "aws_route_table" "publicrt" {
  vpc_id = aws_vpc.myvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}
### route table association to public subnet:
resource "aws_route_table_association" "publicassociation" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.publicrt.id
}
### EC2 instance creation in multiple region. IN our example, mumbai and virginia:
resource "aws_instance" "myec2" {
  ami           = "ami-08e0ca9924195beba"
  instance_type = "t2.micro"

  tags = {
    Name = "small-vm"
  }
}
provider "aws" {
  region = "us-east-1"
  alias  = "useast1"
}
resource "aws_instance" "myec2useast" {
  ami           = "ami-096fda3c22c1c990a"
  instance_type = "t2.micro"
  provider      = aws.useast1

  tags = {
    Name = "small-vm"
  }
}

### This is the ouput of EC2 instances, which shows the IP address of it
output "publicip_apsouth" {
  value = aws_instance.myec2.public_ip
}
output "publicip_useast" {
  value = aws_instance.myec2useast.public_ip
}

### Just a test S3 bucket creation:
resource "aws_s3_bucket" "esh-bucket" {
  bucket = "esh-dev-bucket"
  acl    = "private"
  tags = {
    Name        = "Created by terraform"
    Environment = "prod-Env"
  }
  versioning {
    enabled = true
  }
}

### RDS Database creation:
resource "aws_db_instance" "testdb" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "8.0.19"
  instance_class       = "db.t2.micro"
  name                 = "mydb"
  username             = "root"
  password             = "login1-2"
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
}

# Application Load balancer creation:-
