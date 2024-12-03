#Load Balancer 

# Create Security Group for the Load Balancer
resource "aws_security_group" "qa_alb_sg" {
  name        = "qa_alb_sg"
  vpc_id     = var.dev_vpc_id.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks  = ["0.0.0.0/0"]  # Allow HTTP traffic from anywhere
  }

  # Egress (outbound) rule to allow all traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Allow all outbound traffic
  }
}

#Application Load Balancer 
resource "aws_lb" "qa_load_balancer" {
  name               = "qa-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.qa_alb_sg]
  subnets            = aws_subnet.qa_pr

  enable_deletion_protection = true

  tags = {
    Environment = "QA"
  }
}


#ALB Target Group 
resource "aws_lb_target_group" "qa_app_tg" {
  name     = "qa-app-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = var.dev_vpc_id.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "qa-alb-target-group"
  }
}

#ALB Listener
# lb listener
resource "aws_lb_listener" "qa_app_listener" {
  load_balancer_arn = aws_lb.qa_load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.qa_app_tg.arn
  }
}
# Register EC2 Instances to the Target Group
resource "aws_lb_target_group_attachment" "qa_frontend_attachment" {
    count = 2
  target_group_arn = aws_lb_target_group.qa_app_tg
  target_id        = var.qa_frontend_instance_id[count.index]
  port             = 3000
}
