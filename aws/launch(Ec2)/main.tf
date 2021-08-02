provider "aws" {
	  region="ap-south-1"
}

resource "aws_instance" "firstInstance" {
	  ami           = "ami-0e306788ff2473ccb"
	  instance_type = "t2.micro"
  	  key_name="deepak"
 #	  security_groups=["launch-wizard-9"]  
	  tags={
		Name="firstTF"
		} 
}