############################### EXTERNAL ALB LISTENER RULE ###############################

# HTTP — CloudFront forwards /api/* here over port 80
resource "aws_lb_listener_rule" "http_auth" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.auth.arn
  }

  condition {
    path_pattern {
      values = ["/auth", "/auth/*"]
    }
  }
}

resource "aws_lb_listener_rule" "http_product" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.product.arn
  }

  condition {
    path_pattern {
      values = ["/products", "/products/*", "/singleProduct", "/singleProduct/*"]
    }
  }
}

resource "aws_lb_listener_rule" "http_cart" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 30

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.cart.arn
  }

  condition {
    path_pattern {
      values = ["/cart", "/cart/*", "/orders", "/orders/*"]
    }
  }
}
