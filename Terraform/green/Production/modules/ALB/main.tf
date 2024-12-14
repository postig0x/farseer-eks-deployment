#Load Balancer 

# Create Security Group for the Load Balancer
resource "aws_security_group" "alb_sg" {
  name        = "farseer_alb_sg"
  vpc_id     = var.vpc_id
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
resource "aws_lb" "load_balancer" {
  name               = "farseer-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [var.private_subnet_id1, var.private_subnet_id2]

  enable_deletion_protection = false

  tags = {
    Environment = "production"
  }
}


#ALB Target Group 
resource "aws_lb_target_group" "app_tg" {
  name     = "app-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "farseer-alb-target-group"
  }
}

#ALB Listener
# lb listener
resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}
# Register EC2 Instances to the Target Group
resource "aws_lb_target_group_attachment" "frontend_attachment1" {
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = var.frontend1
  port             = 3000
}

resource "aws_lb_target_group_attachment" "frontend_attachment2" {
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = var.frontend2
  port             = 3000
}