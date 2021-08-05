provider "aws" {
	region="ap-south-1"
}

resource "aws_instance" "firstInstance" {
	ami= var.aws_ami
	instance_type = var.aws_instance_type
  	key_name="deepak"
 	security_groups=["launch-wizard-9"]  
	tags={
		Name="firstTF"
		}
	  
}