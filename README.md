# terraform-aws-ecs

1. Networking: triển khai trên 2 zone (khuyến nghị tạo 2 subnet tương ứng)
    - Sử dụng module có sẵn của terraform
    - Tạo 2 public subnet, 2 private subnet
    - Tạo public route table, private route table (VPC tự tạo thêm 1 route table local) -> 3 route table
    - Internet gateway (IG), NAT gateway (Thời gian tạo sẽ lâu)

    -> output
        vpc_id
        private_subnet_ids
        public_subnet_ids

2. Security: 
    - SG thuộc 1 VPC nào đó
        vpc_id = module.networking.vpc_id (vpc_id lấy từ output networking từ bước 1)

    - tạo các group: 
        - public-SG: 
            - inbound: cho phép request từ ALB (HTTP 80, HTTPS 443, SSH 22)
            - outbound: cho phép các gói tin đi ra ngoài (đang để all: đi đâu cũng ok)
        - private-SG: 
            - inbound: mở cổng nào thì public-SG sẽ dc vào cổng đó (8080 ECS, 3306 RDS)
            - outbound: cho phép các gói tin đi ra ngoài (đang để all: đi đâu cũng ok)
        - Ngoài ra aws tạo sẵn 1 SG default (k sử dụng)

    -> output
        public_security_group_id
        private_security_group_id

3. Bastion
    - Tạo 1 SG riêng cho Bastion
    - Gán cho Bastion 1 subnet - 
        subnet_id = module.networking.public_subnet_ids[0] (subnet ip lấy từ output vpc)
    

    - Có thể có nhiều ng truy cập dc Bastion 
        Cung cấp file .pem (public key vào folder key) -> thêm tên file vào variable.tf -> thêm vào user-data

    - Gán cho Bastion 1 Elastic IP 
    
4. Database (MySql)
        