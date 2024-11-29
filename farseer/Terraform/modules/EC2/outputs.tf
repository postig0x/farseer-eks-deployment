output "farseer_frontend_instance_id" {
  value= aws_instance.farseer-frontend[*].id
}
