output "alb_dns" {
  value = aws_lb.server-alb.dns_name
}

output "ip-server" {
  value = aws_instance.server.private_ip
}

