# terraform-aws-ecs

1. Networking: triển khai trên 2 zone (khuyến nghị tạo 2 subnet tương ứng)
    - Sử dụng module có sẵn của terraform
    - Tạo 2 public subnet, 2 private subnet
    - Tạo public route table, private route table (VPC tự tạo thêm 1 route table local) -> 3 route table
    - Internet gateway (IG), NAT gateway (Thời gian tạo sẽ lâu)