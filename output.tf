output "instance_ip" {
  value = [for instance in aws_instance.dev.*.public_i: {group = instance}]
}