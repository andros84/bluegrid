# Terraform and Ansible automation script for deploying HA web environment on AWS
Requirements:
* Terraform (terraform version 0.11 or 0.12)
* Ansible 

# Download and start Terraform script
* `git clone https://github.com/andros84/bluegrid.git` - Clone this repo.
* `cd bluegrid`
* `terraform init` - Initialize terraform
* `terraform apply` - Apply terraform execution plan.

Script will ask you to enter:
* aws_access_key    - Enter your aws_access_key 
* aws_secret_key    - Enter your aws_secret_key
* your_public_ip    - This is used to allow ssh access to EC2 instance. Enter IP address in form of xxx.xxx.xxx.xxx/32
* name              - How this envirnoment will be called
* region            - AWS region in which this environment will be created
* webserver_count   - Number of EC2 instances that will be created 

# Install Wordpress
After terraform apply command is finished successfully you will need to do: 

1. Connect to all created web servers using ssh. Use terraform output IPs instead of "webserver-ip"  to connect to EC2 instances. 
`ssh ec2-user@webserver-IP -i .key/andrija.pem`

2. Edit wp-config.php file (file location /var/www/wordpress/wp-config.php) on all EC2 instances and add DB_HOST endpoint. Use wp_db_end_point from terraform output for DB_HOST. Example how the line supposed to look after editing:
`define( 'DB_HOST', 'blue-demo-wp-db.cjqcpsybn9bk.eu-west-1.rds.amazonaws.com' );`

Database credentials (db_name, db_username and db_pass) are already set in vars.tf and template for wp-config.php file.

3. Restart nginx web servere with command:
`sudo systemctl restart nginx`

4. Open browser and navigate to aws load balancer use load_balancer_dns_name from terraform output. Example `load_balancer_dns_name = blue-http-elb-45755203.eu-west-1.elb.amazonaws.com` and create wordpress user.


# Created Infrastructure with this script:
* VPC with 2 subnets, internet gateway, route tables.
* Load_balancer that forwards traffic to web servers target group on port 80.
* Target group where targets are all EC2 instances created by this script listening on port 80.
* EC2 t2.micro instances with 8GB of storage.
* One mysql5.7.22 db.t2.micro RDS with 10G allocated storage.
* 3 security groups:
    * ssh_sg - Allows traffic on port 22 only from your public ip address.
    * web_sg - Allows all inbound traffic on port 80 and 443.
    * db_sg  - Allows trafic on port 3306 from your public ip and VPC
