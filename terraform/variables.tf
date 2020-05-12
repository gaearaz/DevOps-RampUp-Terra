variable "ami" {
    type = string
    default = "ami-0e84e211558a022c0"
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
variable "vpc" {
    type = string
    default = "vpc-64b5f70d"
}
# variable "image_id" {
#   type = string
# }