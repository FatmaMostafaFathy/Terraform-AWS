output "public_subnets_id" {
  value = ["${aws_subnet.pub-subnet.id}"]
}

output "private_subnets_id" {
  value = ["${aws_subnet.private-subnet.id}"]
}

#output "instance_ip" {
 #   value = aws_instance.instance.public_ip
#}

#output "instance2_ip" {
 #   value = aws_instance.instance2.private_ip
#}