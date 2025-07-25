
 AWS VPC Peering Project: Nginx and MySQL Communication

This project demonstrates how to establish a VPC peering connection between two Virtual Private Clouds (VPCs) in AWS. We will deploy an Nginx web server in one VPC and a MySQL database server in another. The goal is to enable communication between the two instances over their private IP addresses, showcasing a secure and private network configuration.




## Project Overview

VPC peering is a networking connection between two VPCs that enables you to route traffic between them privately. Instances in either VPC can communicate with each other as if they are within the same network. This project focuses on setting up such a connection and demonstrating its functionality by deploying a web application stack across two peered VPCs. Specifically, an Nginx web server residing in `VPC-1` will connect to a MySQL database server hosted in `VPC-2`. This setup is common in scenarios where different services or environments are isolated in separate VPCs for security, organizational, or compliance reasons, but still require inter-communication.

### Key Objectives:

*   **Establish VPC Peering:** Create and configure a VPC peering connection between two distinct VPCs.
*   **EC2 Instance Deployment:** Launch and configure two EC2 instances, one in each VPC.
*   **Nginx Deployment:** Install and configure Nginx on the EC2 instance in `VPC-1`.
*   **MySQL Deployment:** Install and configure MySQL on the EC2 instance in `VPC-2`.
*   **Network Connectivity Verification:** Confirm network reachability between the EC2 instances using private IP addresses.
*   **Application-Level Connectivity:** Verify that the Nginx server can successfully connect to and interact with the MySQL database across the peered connection.
*   **Database User Access:** Demonstrate secure database access from `VPC-1` to `VPC-2` using a dedicated MySQL user.

This README will guide you through the entire process, from setting up the AWS infrastructure to verifying the application-level connectivity.




## Architecture

The architecture for this project involves two distinct AWS VPCs, `VPC-1` and `VPC-2`, connected via a VPC peering connection. Each VPC will host an EC2 instance, and appropriate security groups and route tables will be configured to facilitate communication.

*   **VPC-1 (Requester VPC):**
    *   **CIDR Block:** `10.0.0.0/16` (Example)
    *   **Subnet:** `10.0.1.0/24` (Example)
    *   **EC2 Instance:** `Nginx-Server` (Amazon Linux 2, t2.micro)
        *   **Role:** Hosts the Nginx web server.
        *   **Security Group:** Allows inbound traffic on port 80 (HTTP) from anywhere (for Nginx access) and all traffic from `VPC-2`'s CIDR block (for database connectivity).
    *   **Route Table:** Contains a route to `VPC-2`'s CIDR block via the VPC peering connection.

*   **VPC-2 (Accepter VPC):**
    *   **CIDR Block:** `10.1.0.0/16` (Example)
    *   **Subnet:** `10.1.1.0/24` (Example)
    *   **EC2 Instance:** `MySQL-Server` (Amazon Linux 2, t2.micro)
        *   **Role:** Hosts the MySQL database server.
        *   **Security Group:** Allows inbound traffic on port 3306 (MySQL) from `VPC-1`'s CIDR block.
    *   **Route Table:** Contains a route to `VPC-1`'s CIDR block via the VPC peering connection.

*   **VPC Peering Connection:**
    *   A direct network connection between `VPC-1` and `VPC-2`.
    *   Enables instances in both VPCs to communicate using private IP addresses.
    *   Crucially, VPC peering connections are non-transitive, meaning if `VPC-1` is peered with `VPC-2`, and `VPC-2` is peered with `VPC-3`, `VPC-1` cannot directly communicate with `VPC-3` unless a separate peering connection is established.

This setup ensures that the Nginx server in `VPC-1` can securely and privately access the MySQL database in `VPC-2` without traversing the public internet.




## Prerequisites

Before you begin, ensure you have the following:

*   **AWS Account:** An active AWS account with appropriate permissions to create VPCs, EC2 instances, security groups, and peering connections.
*   **Basic AWS Knowledge:** Familiarity with AWS console navigation, VPC concepts (subnets, route tables, security groups), and EC2 instance management.
*   **AWS CLI (Optional but Recommended):** The AWS Command Line Interface installed and configured for easier management of AWS resources. You can perform all steps via the AWS Management Console as well.
*   **SSH Client:** An SSH client (e.g., OpenSSH, PuTTY) to connect to your EC2 instances.




## Implementation Steps

Follow these steps to set up your AWS VPC peering environment and deploy the Nginx and MySQL instances.

### 1. Create VPCs

First, create two new VPCs with non-overlapping CIDR blocks.

**VPC-1 (Requester VPC):**

1.  Navigate to the **VPC Dashboard** in the AWS Management Console.
2.  Click **Create VPC**.
3.  Provide a **Name tag** (e.g., `VPC-1-Nginx`).
4.  Set **IPv4 CIDR block** to `10.0.0.0/16`.
5.  Leave other settings as default and click **Create VPC**.

**VPC-2 (Accepter VPC):**

1.  Navigate to the **VPC Dashboard**.
2.  Click **Create VPC**.
3.  Provide a **Name tag** (e.g., `VPC-2-MySQL`).
4.  Set **IPv4 CIDR block** to `10.1.0.0/16`.
5.  Leave other settings as default and click **Create VPC**.

### 2. Create Subnets

Create a public subnet within each VPC.

**Subnet for VPC-1:**

1.  In the VPC Dashboard, go to **Subnets** and click **Create subnet**.
2.  Select `VPC-1-Nginx` from the **VPC ID** dropdown.
3.  Provide a **Subnet name** (e.g., `VPC-1-Nginx-Subnet`).
4.  Choose an **Availability Zone**.
5.  Set **IPv4 CIDR block** to `10.0.1.0/24`.
6.  Click **Create subnet**.

**Subnet for VPC-2:**

1.  In the VPC Dashboard, go to **Subnets** and click **Create subnet**.
2.  Select `VPC-2-MySQL` from the **VPC ID** dropdown.
3.  Provide a **Subnet name** (e.g., `VPC-2-MySQL-Subnet`).
4.  Choose an **Availability Zone** (can be the same or different from VPC-1's subnet).
5.  Set **IPv4 CIDR block** to `10.1.1.0/24`.
6.  Click **Create subnet**.

### 3. Create Internet Gateways (Optional, for public access to Nginx)

An Internet Gateway is needed for `VPC-1` if you want to access the Nginx web server from the internet. For `VPC-2`, an Internet Gateway is not strictly necessary if the MySQL instance only needs to be accessed from `VPC-1`.

**Internet Gateway for VPC-1:**

1.  In the VPC Dashboard, go to **Internet Gateways** and click **Create internet gateway**.
2.  Provide a **Name tag** (e.g., `VPC-1-Nginx-IGW`).
3.  Click **Create internet gateway**.
4.  Select the newly created Internet Gateway and click **Actions** -> **Attach to VPC**.
5.  Select `VPC-1-Nginx` and click **Attach internet gateway**.
![vpc perring](https://github.com/rukevweubio/Terraform/blob/main/vpc-peering/screenshot/Screenshot%20(1712).png)

### 4. Configure Route Tables

Update the route tables for both VPCs to allow traffic to flow through the peering connection.

**Route Table for VPC-1:**

1.  In the VPC Dashboard, go to **Route Tables**.
2.  Select the route table associated with `VPC-1-Nginx` (usually the one created by default with the VPC).
3.  Go to the **Routes** tab and click **Edit routes**.
4.  Click **Add route**.
5.  For **Destination**, enter `10.1.0.0/16` (CIDR of VPC-2).
6.  For **Target**, select **Peering Connection** and then choose the peering connection you will create in the next step (you'll come back to this step after creating the peering connection).
7.  If you created an Internet Gateway for VPC-1, ensure there's a route for `0.0.0.0/0` (all internet traffic) pointing to the `VPC-1-Nginx-IGW`.
8.  Click **Save changes**.

![vpc perring](https://github.com/rukevweubio/Terraform/blob/main/vpc-peering/screenshot/Screenshot%20(1714).png)

**Route Table for VPC-2:**

1.  In the VPC Dashboard, go to **Route Tables**.
2.  Select the route table associated with `VPC-2-MySQL`.
3.  Go to the **Routes** tab and click **Edit routes**.
4.  Click **Add route**.
5.  For **Destination**, enter `10.0.0.0/16` (CIDR of VPC-1).
6.  For **Target**, select **Peering Connection** and then choose the peering connection you will create in the next step (you'll come back to this step after creating the peering connection).
7.  Click **Save changes**.

### 5. Create VPC Peering Connection

Now, create the peering connection between `VPC-1` and `VPC-2`.

1.  In the VPC Dashboard, go to **Peering Connections** and click **Create peering connection**.
2.  Provide a **Name** (e.g., `VPC1-VPC2-Peering`).
3.  For **Requester VPC**, select `VPC-1-Nginx`.
4.  For **Accepter VPC**, select `My AWS account` (if in the same account) and `VPC-2-MySQL`.
5.  Click **Create peering connection**.
6.  The peering connection will be in a `Pending Acceptance` state. Select the peering connection and click **Actions** -> **Accept request**.
7.  Confirm the acceptance.

![vpc perring](https://github.com/rukevweubio/Terraform/blob/main/vpc-peering/screenshot/Screenshot%20(1713).png)

**Important:** After accepting the peering connection, go back to **Step 4** and update the route tables for both VPCs with the newly created peering connection as the target for the respective destination CIDR blocks.

### 6. Configure Security Groups

Create and configure security groups for your EC2 instances.

**Security Group for Nginx-Server (VPC-1):**

1.  In the VPC Dashboard, go to **Security Groups** and click **Create security group**.
2.  Provide a **Security group name** (e.g., `Nginx-SG`) and **Description**.
3.  Select `VPC-1-Nginx` for **VPC**.
4.  **Inbound rules:**
    *   **Type:** HTTP, **Source:** Anywhere (`0.0.0.0/0`)
    *   **Type:** SSH, **Source:** Your IP (or `0.0.0.0/0` for testing, but less secure)
    *   **Type:** All TCP, **Source:** `10.1.0.0/16` (VPC-2's CIDR block - allows Nginx to connect to MySQL)
5.  Click **Create security group**.

**Security Group for MySQL-Server (VPC-2):**

1.  In the VPC Dashboard, go to **Security Groups** and click **Create security group**.
2.  Provide a **Security group name** (e.g., `MySQL-SG`) and **Description**.
3.  Select `VPC-2-MySQL` for **VPC**.
4.  **Inbound rules:**
    *   **Type:** MySQL/Aurora (Port 3306), **Source:** `10.0.0.0/16` (VPC-1's CIDR block - allows Nginx to connect to MySQL)
    *   **Type:** SSH, **Source:** Your IP (or `0.0.0.0/0` for testing)
5.  Click **Create security group**.
![vpc perring](https://github.com/rukevweubio/Terraform/blob/main/vpc-peering/screenshot/Screenshot%20(1716).png)

![vpc perring](https://github.com/rukevweubio/Terraform/blob/main/vpc-peering/screenshot/Screenshot%20(1717).png)

### 7. Launch EC2 Instances

Launch one EC2 instance in each VPC.

**EC2 Instance in VPC-1 (Nginx-Server):**

1.  Navigate to the **EC2 Dashboard**.
2.  Click **Launch instances**.
3.  Choose an **Amazon Machine Image (AMI)** (e.g., Amazon Linux 2 AMI).
4.  Choose an **Instance type** (e.g., `t2.micro`).
5.  **Network settings:**
    *   **VPC:** `VPC-1-Nginx`
    *   **Subnet:** `VPC-1-Nginx-Subnet`
    *   **Auto-assign public IP:** Enable (if you want public access to Nginx)
6.  **Security groups:** Select the existing `Nginx-SG`.
7.  **Key pair:** Choose an existing key pair or create a new one.
8.  Add a **Name tag** (e.g., `Nginx-Server`).
9.  Click **Launch instance**.

**EC2 Instance in VPC-2 (MySQL-Server):**

1.  Navigate to the **EC2 Dashboard**.
2.  Click **Launch instances**.
3.  Choose an **Amazon Machine Image (AMI)** (e.g., Amazon Linux 2 AMI).
4.  Choose an **Instance type** (e.g., `t2.micro`).
5.  **Network settings:**
    *   **VPC:** `VPC-2-MySQL`
    *   **Subnet:** `VPC-2-MySQL-Subnet`
    *   **Auto-assign public IP:** Disable (if MySQL only needs to be accessed privately from VPC-1)
6.  **Security groups:** Select the existing `MySQL-SG`.
7.  **Key pair:** Choose the same key pair used for Nginx-Server or a new one.
8.  Add a **Name tag** (e.g., `MySQL-Server`).
9.  Click **Launch instance**.

### 8. Install and Configure Nginx on Nginx-Server

SSH into your `Nginx-Server` EC2 instance using its public IP address.

```bash
sudo yum update -y
sudo amazon-linux-extras install nginx1 -y
sudo systemctl start nginx
sudo systemctl enable nginx
```

Verify Nginx is running by accessing its public IP in a web browser. You should see the Nginx welcome page.

### 9. Install and Configure MySQL on MySQL-Server

SSH into your `MySQL-Server` EC2 instance using its public IP address (if enabled) or a bastion host in VPC-2.

```bash
sudo yum update -y
sudo yum install mysql-server -y
sudo systemctl start mysqld
sudo systemctl enable mysqld
sudo mysql_secure_installation
```

During `mysql_secure_installation`, set a strong root password, remove anonymous users, disallow root login remotely, remove test database, and reload privilege tables.

### 10. Create MySQL User for VPC-1 Access

From your `MySQL-Server` EC2 instance, log in to MySQL as root and create a new user that can be accessed from `VPC-1`'s CIDR block. Replace `your_password` with a strong password.

```sql
sudo mysql -u root -p

CREATE USER 'nginx_user'@'10.0.0.0/16' IDENTIFIED BY 'your_password';
GRANT ALL PRIVILEGES ON *.* TO 'nginx_user'@'10.0.0.0/16' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EXIT;
```

This creates a user `nginx_user` that can connect from any IP address within `VPC-1`'s CIDR block (`10.0.0.0/16`).




## Testing and Verification

After setting up the infrastructure, it's crucial to verify connectivity and application-level communication.

### 1. Ping Instances by Private IP

**From Nginx-Server (VPC-1) to MySQL-Server (VPC-2):**

1.  SSH into your `Nginx-Server` instance.
2.  Find the private IP address of your `MySQL-Server` instance (e.g., `10.1.1.x`).
3.  Execute the ping command:
    ```bash
    ping <MySQL-Server-Private-IP>
    ```
    You should see successful replies, indicating network connectivity.

**From MySQL-Server (VPC-2) to Nginx-Server (VPC-1):**

1.  SSH into your `MySQL-Server` instance.
2.  Find the private IP address of your `Nginx-Server` instance (e.g., `10.0.1.x`).
3.  Execute the ping command:
    ```bash
    ping <Nginx-Server-Private-IP>
    ```
    You should also see successful replies.

### 2. Access MySQL Database from Nginx-Server

This step verifies that the Nginx server can connect to the MySQL database using the `nginx_user` created earlier.

1.  SSH into your `Nginx-Server` instance.
2.  Install the MySQL client:
    ```bash
    sudo yum install mysql -y
    ```
3.  Attempt to log in to the MySQL database on `MySQL-Server` using its private IP address and the `nginx_user`:
    ```bash
    mysql -h <MySQL-Server-Private-IP> -u nginx_user -p
    ```
    When prompted, enter the password you set for `nginx_user`. If successful, you will be logged into the MySQL prompt, confirming that the Nginx server can access the database across the VPC peering connection.

    To exit the MySQL prompt, type `exit;` and press Enter.

### 3. (Optional) Configure Nginx to Serve Dynamic Content from MySQL

To further demonstrate connectivity, you can set up a simple PHP application on the Nginx server that connects to the MySQL database. This requires installing PHP and a PHP MySQL driver on the Nginx server.

**On Nginx-Server:**

1.  Install PHP and MySQL extension:
    ```bash
    sudo amazon-linux-extras install php7.4 -y
    sudo yum install php-mysqlnd -y
    ```
2.  Configure Nginx to process PHP files. Edit the Nginx configuration file (e.g., `/etc/nginx/nginx.conf` or create a new one in `/etc/nginx/conf.d/`). Add a `location` block for PHP files:
    ```nginx
    location ~ \.php$ {
        root           /usr/share/nginx/html;
        fastcgi_pass   unix:/run/php-fpm/www.sock;
        fastcgi_index  index.php;
        fastcgi_param  SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include        fastcgi_params;
    }
    ```
3.  Restart Nginx and PHP-FPM:
    ```bash
    sudo systemctl start php-fpm
    sudo systemctl enable php-fpm
    sudo systemctl restart nginx
    ```
4.  Create a simple PHP file (e.g., `/usr/share/nginx/html/db_test.php`) to connect to MySQL:
    ```php
    <?php
    $servername = "<MySQL-Server-Private-IP>";
    $username = "nginx_user";
    $password = "your_password"; // Replace with your actual password
    $dbname = "mysql"; // You can use any existing database, or create a new one

    // Create connection
    $conn = new mysqli($servername, $username, $password, $dbname);

    // Check connection
    if ($conn->connect_error) {
        die("Connection failed: " . $conn->connect_error);
    }
    echo "Connected to MySQL successfully!";
    $conn->close();
    ?>
    ```
  

