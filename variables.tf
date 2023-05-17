variable "cidr" {
    description = "cidr of vpc"
    default = "10.0.0.0/16"

}
 
variable "pubsubnet" {
    description = "cidr of subnet"
    default = "10.0.0.0/24"
}

variable "pvsubnet"{
    description = "cidr of subnet"
    default = "10.0.1.0/24"
}