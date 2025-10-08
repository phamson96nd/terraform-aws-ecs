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
    
    - Note: Nên chỉnh sửa chỉ cho IP cong ty truy cập vào (Hiện tại để inbound 0.0.0.0/0)
        cidr_blocks = ["0.0.0.0/0"] #Allow SSH from anywhere, todo: restrict to your IP
    
4. Database (MySql)
    - Hiện tại chỉ tạo instance KHÔNG tạo db_name (tạo trong ECS cluster)
    - identifier = "${var.app_name}-mysql" -> chú ý đặt tên app_name dạng gạch ngang (vd: laravel-1)
    - Thêm 1 security group riêng cho DB: 
        ssh 
        Các instance trong private security group
        
    - Đã setting instance chạy trên 2 private subnet
        (nhưng trong setup mysql vẫn chưa cho multi az
        -> chuyển multi az thành true để có  High Availability)


5. Load balancer
    - Tạo target group FE
    - Tạo target group BE

6. ECS
    1. Create cluster
    2. ECS Task Execution Role + Policy (Được ECS dùng khi khởi chạy container — trước khi ứng dụng của bạn chạy.)
        Pull imgage ECR
        Log cloudWatch
        Giải mã bí mật AWS Secrets Manager
    3. ECS Task  (Code của bạn cần thứ gì ...)
        Ghi file lên S3
        Gửi messages vào SQS
        Lấy secret riêng của app từ Secrets Manager
        
    ####### Frontend ######
    ####### Backend  ######    

7. ECR 


8. Codepipeline + CodeBuild + Github
    Luồng 
        -> Source:
            Kết nối source git qua Connections(tạo tay và kết nối qua arn)
        -> Build:
            buildspec.yml 
                -> build image và push lên ECR
                -> imagedefinitions.json
        -> Deploy
            ECS tạo task definitions revision mới đọc từ imagedefinitions.json
            ECS Service update
                Contairner mới chạy


    Ngoài ra cần S3: Vai trò của S3 trong CodePipeline
        Artifact store
            CodePipeline hoạt động dựa trên artifacts (tệp trung gian giữa các stage).

        Ví dụ:
            Source stage: lấy code từ GitHub → tạo artifact SourceOutput.
            Build stage: nhận artifact SourceOutput, build Docker image → tạo artifact BuildOutput (có imagedefinitions.json).
            Deploy stage: đọc BuildOutput để update ECS Service.
            S3 dùng để lưu trữ các artifact này tạm thời giữa các stage