variable "ami" {
    type = string
    default = "ami-07c1207a9d40bc3bd"
}
variable "availability-zones" {
    type = list
    default = ["us-east-2a", "us-east-2b", "us-east-2c"]
}
variable "default-subnet2-list-abc" {
    type = list
    default = ["subnet-966331ff", "subnet-d28b2a9f", "subnet-d28b2a9f"]
}
variable "instance-type" {
    type = string
    default = "t2.micro"
}
variable "key-name" {
    type = string
    default = "perfZapataKey"
}
variable "proj-tag" {
    type = string
    default = "azapatao-rampup"
}
variable "resp-tag" {
    type = string
    default = "azapatao"
}
variable "security-groups" { #First: default-ssh-example-2, Second: 
    type = list
    default = ["sg-053c77de0b13a7275"]
}
variable "vpc" {
    type = string
    default = "vpc-64b5f70d"
}
