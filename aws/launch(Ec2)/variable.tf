// made seperate file for variable

variable "aws_ami" {
  type        = string
  description = "variable for AWS image"
}
variable "aws_instance_type" {
  type        = string
  description = "variable for instance type"
}
variable "webserver" {
  type = set(string)
  default = ["web1","web2","web3"]
}