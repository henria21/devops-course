# Terraform

## Part 1 — Quick Recap
### 1. What does terraform init do?
- Downloads provider plugins
- Creates .terraform/ directory
- Initializes backend (if exists)
👉 Without init → nothing works

### 2. Difference between plan and apply?
- **plan** — shows what Terraform *would* change (read-only, no changes applied):
  - Reads `.tf` files
  - Reads current state
  - Queries real infrastructure
  - Builds execution plan
- **apply** — executes the changes and updates real infrastructure
👉 Always run plan before apply to review changes first

## Part 2 — Project Setup (Hands-on)

Folder structure:
terraform-aws-lesson/
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars


### 3. What is state?
- Stored in `terraform.tfstate`
- Contains: Resource IDs, Metadata, Dependency info
- Terraform does NOT scan AWS fully — it relies on state to know what exists
⚠️ If state is wrong → infrastructure drift

## Part 2 — Variables

```hcl
variable "aws_region" {
  default = "us-east-1"
}
```
### 1. Why do variables matter?
- **Reuse** — write once, use across many resources instead of hardcoding values
- **Environments** — swap `dev` / `staging` / `prod` by changing a single value
👉 No variables → copy-paste config → drift between environments

## Part 4 — Create a VPC

```hcl
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}
```
### 1. VPC with CIDR
- **CIDR basics** — `10.0.0.0/16` means 65,536 IP addresses; the `/16` is the prefix length (smaller number = more IPs)
- **Why not the default VPC** — default VPC is shared, pre-configured, and not under your control; creating your own gives you isolation, custom IP ranges, and clean security boundaries
👉 In production, always use a custom VPC

## Part 5 — Subnet

### 1. Subnet and resource dependency
```hcl
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
}
```
- `10.0.1.0/24` — a slice of the VPC's `10.0.0.0/16`, giving 256 IPs
- **Implicit dependency** — `aws_vpc.main.id` is a reference; Terraform automatically creates the VPC first before creating the subnet
👉 No need for `depends_on` — Terraform figures out the order from the reference

## Part 6 — Internet Access

### 1. How internet access works in a VPC
```hcl
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.rt.id
}
```
- **Internet Gateway** — attaches to the VPC, acts as the door to the internet
- **Route Table** — defines where traffic goes; `0.0.0.0/0` means "all traffic" → send to the gateway
- **Route Table Association** — links the route table to the subnet, making it a *public* subnet
👉 Without all 4 resources wired together, instances in the subnet have no internet access

## Part 7 — Security Group

### 1. Security Group for SSH
```hcl
resource "aws_security_group" "ssh" {
  name        = "allow_ssh"
  description = "Allow SSH access"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # risky — open to the entire internet
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```
- **ingress** — controls inbound traffic; port 22 = SSH
- **egress** — controls outbound traffic; `-1` protocol means all traffic allowed out
- ⚠️ `cidr_blocks = ["0.0.0.0/0"]` on ingress means anyone on the internet can attempt SSH — exposes the server to brute-force and scanning attacks
👉 In production, restrict ingress to your IP only: `["YOUR_IP/32"]`

## Part 8 — EC2 Instance (Free Tier Safe)

### 1. Launching an EC2 instance
```hcl
resource "aws_instance" "web" {
  ami                         = "ami-0c02fb55956c7d316" # Amazon Linux (example)
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.ssh.id]
  associate_public_ip_address = true

  tags = {
    Name = "Terraform-Student-Instance"
  }
}
```
- **AMI** — Amazon Machine Image; a pre-built snapshot of an OS (like Amazon Linux, Ubuntu). The AMI ID is region-specific — the same ID won't work in a different region
- **Free tier limits** — `t2.micro` is free for up to 750 hours/month for the first 12 months; always destroy with `terraform destroy` after class to avoid charges
- `associate_public_ip_address = true` — assigns a public IP so you can SSH in from outside the VPC
👉 Forgetting `terraform destroy` = surprise AWS bill at end of month

### 2. SSH into the instance (WSL)
After apply, the key file is saved locally. Copy it to the WSL filesystem so permissions work:
```bash
cp /mnt/c/Users/henri/source/repos/devops-course/class12/terraform/terraform-key.pem ~/terraform-key.pem
chmod 600 ~/terraform-key.pem
ssh -i ~/terraform-key.pem ec2-user@$(terraform output -raw public_ip)
```
- `cp` to `~/` — moves the key off the Windows filesystem where `chmod` doesn't work
- `chmod 600` — SSH refuses keys that are readable by others; 600 = only owner can read/write
👉 Always keep `.pem` files on the Linux filesystem when using WSL

## Part 9 — Outputs

### 1. Exposing values after apply
```hcl
output "public_ip" {
  value = aws_instance.web.public_ip
}
```
- Outputs print values to the terminal after `terraform apply`
- Reference any resource attribute using `resource_type.name.attribute`
- Can also be read later with `terraform output public_ip`
👉 Useful for passing values to scripts or teammates without digging through state

## Part 10 — Separate State Per Environment

### 1. Why separate state?
- Each environment (dev/prod) must have its own state file
- Sharing state = Terraform sees different values (e.g. different subnet CIDR) and destroys/recreates shared resources
- ⚠️ Real incident: running prod after dev destroyed the subnet + EC2 instance because the CIDR changed

### 2. How to apply per environment
Backend is S3 — use `key` to separate state per environment (not `path`, which is local-only):
```bash
# Dev
terraform init -backend-config="key=dev/terraform.tfstate" -reconfigure
terraform apply -var-file="environments/dev.tfvars"

# Prod
terraform init -backend-config="key=prod/terraform.tfstate" -reconfigure
terraform apply -var-file="environments/prod.tfvars"
```
- `key` — the S3 object path for the state file; each environment gets its own
- `-reconfigure` — required when switching state between environments
- `backend.tf` must have `key` removed so it can be passed at init time (partial config)
👉 Skipping `-reconfigure` = both environments share the same state = they destroy each other

### 3. Destroy per environment
```bash
# Destroy dev only
terraform init -backend-config="key=dev/terraform.tfstate" -reconfigure
terraform destroy -var-file="environments/dev.tfvars"

# Destroy prod only
terraform init -backend-config="key=prod/terraform.tfstate" -reconfigure
terraform destroy -var-file="environments/prod.tfvars"
```
👉 In real projects, dev and prod live in separate AWS accounts entirely — not just separate state files

### 4. Gotcha — different subnet CIDRs with a shared VPC
If dev and prod use **different** subnet CIDRs but share the same VPC, Terraform will destroy and recreate the subnet (and the EC2 instance with it) when switching environments:
```
~ cidr_block = "10.0.1.0/24" -> "10.0.2.0/24" # forces replacement
```
- Different CIDRs only work when each environment has its **own VPC**
- In a shared-VPC class setup, use the **same CIDR** across environments
👉 Real fix: separate VPCs per environment, or separate AWS accounts entirely

### 5. Gotcha — shared AWS resource names across environments
Any resource with a hardcoded name (key pair, security group) will conflict when both environments exist in the same AWS account:
```
Error: InvalidKeyPair.Duplicate: The keypair already exists
```
Fix: prefix all names with `var.environment`:
```hcl
resource "aws_key_pair" "generated" {
  key_name = "${var.environment}-terraform-key"
}

resource "local_file" "private_key" {
  filename = "${var.environment}-key.pem"
}

resource "aws_security_group" "ssh" {
  name = "${var.environment}-allow-ssh"
}
```
SSH with the environment-specific key:
```bash
# Dev
cp /mnt/c/.../terraform/dev-key.pem ~/dev-key.pem
chmod 600 ~/dev-key.pem
ssh -i ~/dev-key.pem ec2-user@<dev_public_ip>

# Prod
cp /mnt/c/.../terraform/prod-key.pem ~/prod-key.pem
chmod 600 ~/prod-key.pem
ssh -i ~/prod-key.pem ec2-user@<prod_public_ip>
```
👉 Any hardcoded name in Terraform = guaranteed collision when running multiple environments in the same AWS account
