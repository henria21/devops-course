# Lesson 12 — Infrastructure as Code with Terraform
> Source: `Class 12 - IaC with Terraform.pptx` (34 slides)

---

## What is Infrastructure as Code (IaC)?

IaC is the practice of:
- Managing infrastructure **using code**
- Automating provisioning and configuration
- Treating infrastructure like software

**Instead of:** ❌ Clicking manually in cloud consoles  
**We use:** ✅ Versioned code files in Git

### What IaC Can Manage
- Virtual machines (EC2)
- Networks (VPC / Subnets)
- Load balancers, databases
- Kubernetes clusters
- DNS, storage
- → Entire cloud environments

---

## Traditional Infrastructure Management (Before IaC)

**Manual approach:**
- System administrators created servers by hand
- Configured networks manually
- Installed software on each machine
- Opened firewall ports one by one

**Problems:**
- Human mistakes, no documentation
- Hard to reproduce environments
- Slow deployments — "works on my machine" problem
- No audit trail, no rollback

---

## Why Infrastructure as Code?

| Benefit | Description |
|---|---|
| ✅ Automation | No manual steps — run a command |
| ✅ Repeatability | Same code = same infrastructure every time |
| ✅ Version Control | Every change in Git — author, timestamp, rollback |
| ✅ Faster Deployments | Minutes instead of hours |
| ✅ Consistency | Identical environments across dev/staging/prod |
| ✅ Scalability | Create 1 or 1,000 servers from the same code |
| ✅ Disaster Recovery | Recreate crashed environment in minutes |
| ✅ Team Collaboration | Pull requests, code review for infrastructure |

### Real World Example
> Production server crashes. Nobody remembers how it was configured.  
> **Without IaC:** ❌ Rebuild manually, takes hours/days  
> **With IaC:** ✅ `terraform apply` → environment recreated in minutes

---

## Types of IaC Approaches

| Approach | Description | Examples |
|---|---|---|
| **Imperative** | Define *how* to do it step-by-step | Bash scripts, Ansible playbooks |
| **Declarative** | Define *what* should exist | Terraform, CloudFormation, Pulumi |

---

## Popular IaC Tools

| Tool | Provider | Model |
|---|---|---|
| **Terraform** | HashiCorp | Declarative, multi-cloud |
| **OpenTofu** | Open-source fork of Terraform | Declarative, multi-cloud |
| **CloudFormation** | AWS | Declarative, AWS-only |
| **Pulumi** | Pulumi | Declarative, code-based |
| **Ansible** | Red Hat | Imperative (mostly) |

---

## What is Terraform?

Terraform is an **Infrastructure as Code engine** that:
- Translates declarative configuration → real infrastructure
- Builds a **dependency graph** of resources
- Executes changes in the correct order

> 💡 Key idea: You describe **what you want**, not **how to do it**

### Why Terraform Became Popular
- **Multi-cloud support** — AWS, Azure, GCP, Kubernetes, GitHub, Datadog
- Huge community and provider ecosystem
- Declarative syntax (HCL — HashiCorp Configuration Language)
- Reusable modules
- Open-source with commercial backing

---

## Terraform Architecture

| Component | Role |
|---|---|
| **Core Engine** | Parses `.tf` files, builds dependency graph, manages state |
| **Providers** | AWS/Azure/GCP plugins — translate Terraform config → API calls |
| **State** | Source of truth for what infrastructure currently exists |

---

## Terraform Workflow (Critical)

```
Write Code → Init → Plan → Apply → State Updated
```

| Step | Command | What happens |
|---|---|---|
| **Write** | Edit `.tf` files | Define desired infrastructure |
| **Init** | `terraform init` | Download providers, initialize backend |
| **Plan** | `terraform plan` | Compare desired vs actual — show what will change |
| **Apply** | `terraform apply` | Execute the plan — create/modify/destroy resources |
| **Destroy** | `terraform destroy` | Remove all managed resources |

---

## Terraform Init

```bash
terraform init
```

- Downloads provider plugins (e.g., AWS provider)
- Creates `.terraform/` directory
- Initializes backend (if remote state is configured)

> ⚠️ Without `init` → nothing works

---

## Terraform Plan

```bash
terraform plan
```

- Reads `.tf` files + current state + queries real infrastructure
- Builds an execution plan showing:
  - `+` = will create
  - `~` = will modify
  - `-` = will destroy

> 💡 Safe step — **no changes made yet**. Always review before applying.

---

## Terraform Apply

```bash
terraform apply
```

- Executes the plan
- Calls provider APIs (e.g., AWS API)
- Creates/modifies/destroys resources
- Updates the state file

> ⚠️ This is the **only step that changes real infrastructure**

---

## Terraform State

File: `terraform.tfstate`

**Contains:**
- Resource IDs
- Metadata
- Dependency information

**Why it matters:**
- Terraform does NOT scan AWS fully on every run
- It relies on **state** to know what exists
- If state is wrong → **infrastructure drift**

> ⚠️ Never edit the state file manually

---

## Project Structure (Best Practice)

```
project/
├── main.tf          # Resource definitions
├── variables.tf     # Input variable declarations
├── outputs.tf       # Output value definitions
├── terraform.tfvars # Actual variable values
└── providers.tf     # Provider configuration
```

---

## HCL Code Examples

### Provider Configuration
```hcl
provider "aws" {
  region = var.aws_region
}
```

### Variables
```hcl
variable "aws_region" {
  type    = string
  default = "us-east-1"
}
```

### `terraform.tfvars`
```hcl
aws_region = "us-east-1"
```

### Resource Block
```hcl
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id
}
```

### Resource Dependencies
```hcl
subnet_id = aws_subnet.public.id
```
Terraform understands that EC2 depends on the subnet → creates subnet first.

### Outputs
```hcl
output "public_ip" {
  value = aws_instance.web.public_ip
}
```

---

## Dependency Graph

Terraform automatically builds an execution graph:
```
VPC → Subnet → EC2
```

- Resources are created in the correct dependency order
- Independent resources are created **in parallel**
- No need to manually define creation order

---

## CLI Commands Reference

```bash
terraform init       # Setup project, download providers
terraform plan       # Preview changes
terraform apply      # Execute changes
terraform destroy    # Remove all resources

terraform validate   # Check syntax
terraform fmt        # Format code (auto-format .tf files)
terraform show       # Inspect current state
```

---

## Common Workflow in Teams

```
1. Write code
2. terraform fmt       ← format
3. terraform validate  ← check syntax
4. terraform plan      ← review changes (team reviews this)
5. terraform apply     ← execute after approval
```

---

## Common Mistakes

| Mistake | Consequence |
|---|---|
| ❌ Hardcoding values | Not reusable, credentials in code |
| ❌ Editing state manually | State corruption, drift |
| ❌ Skipping `plan` | Unexpected changes in production |
| ❌ Not destroying test resources | Unexpected cloud costs |

---

## Treat Infrastructure Like Software

Infrastructure should have:
- **Git repositories** — version-controlled `.tf` files
- **Pull requests** — review changes before applying
- **Code reviews** — catch misconfigurations early
- **CI/CD pipelines** — automated `plan` on PR, `apply` after merge
- **Version history** — full audit trail of infrastructure changes

> 💡 Infrastructure = software project

---

## IaC + DevOps

IaC is a **core DevOps practice**. It enables:
- CI/CD pipelines for infrastructure
- Automated deployments
- Immutable infrastructure
- Cloud scalability

Modern cloud operations depend on IaC.

---

## Key Takeaways

1. IaC = manage infrastructure with code — reproducible, versioned, automated
2. **Declarative** IaC (Terraform): describe what you want, not how to do it
3. Terraform workflow: `init` → `plan` → `apply` — always review the plan first
4. **State** is critical — Terraform uses it as source of truth; never edit manually
5. Dependencies are automatic — Terraform builds an execution graph
6. Treat infrastructure like software: Git, PRs, code review, CI/CD

---

## Assignment

**Goal:** Use Terraform to provision a full AWS environment (VPC, subnet, internet gateway, security group, EC2) and manage multiple environments with separate state files.

**Folder structure:**
```
terraform-aws-lesson/
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
└── environments/
    ├── dev.tfvars
    └── prod.tfvars
```

**Tasks:**
1. **Init/Plan/Apply** — `terraform init`, `terraform plan`, `terraform apply`
2. **Create VPC** — `aws_vpc` with CIDR `10.0.0.0/16`
3. **Add Subnet** — `aws_subnet` with implicit dependency on VPC via reference
4. **Internet Access** — Wire up `aws_internet_gateway` + `aws_route_table` + `aws_route` + `aws_route_table_association`
5. **Security Group** — Allow SSH (port 22); explain why `0.0.0.0/0` is risky
6. **EC2 Instance** — `t2.micro`, Amazon Linux AMI, `associate_public_ip_address = true`
7. **Outputs** — Expose `public_ip` after apply
8. **SSH** — Copy `.pem` key to WSL filesystem, `chmod 600`, SSH in
9. **Environments** — Deploy same code to `dev` and `prod` using `-var-file`, use separate state files (`-state=dev.tfstate` or S3 backend key)
10. **Destroy** — `terraform destroy` per environment to avoid AWS charges

**Key concepts to understand:**
- `terraform init` — downloads provider plugins
- `terraform plan` — shows what *would* change (read-only)
- `terraform apply` — executes changes
- State file (`terraform.tfstate`) — Terraform's record of what exists; if wrong → drift
- Implicit dependency — Terraform resolves order from resource references automatically
- Variables (`var.xxx`) — reuse the same code across environments

---

## Student Answers

**What does `terraform init` do?**
- Downloads provider plugins (e.g., AWS provider)
- Creates `.terraform/` directory
- Initializes backend (if configured)
> Without `init` → nothing works

**Difference between `plan` and `apply`:**
- `plan` — reads `.tf` files, reads state, queries AWS, builds execution plan — no changes made
- `apply` — executes the plan and updates real infrastructure
> Always run `plan` before `apply` to review changes first

**What is state?**
- Stored in `terraform.tfstate`
- Contains resource IDs, metadata, dependency info
- Terraform does NOT scan AWS fully — it relies on state to know what exists
> ⚠️ If state is wrong → infrastructure drift

**Full infrastructure code:**
```hcl
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
}

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

resource "aws_security_group" "ssh" {
  name   = "${var.environment}-allow-ssh"
  vpc_id = aws_vpc.main.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # risky — open to internet; use YOUR_IP/32 in prod
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  ami                         = "ami-0c02fb55956c7d316"
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.ssh.id]
  associate_public_ip_address = true
  tags = { Name = "${var.environment}-server" }
}

output "public_ip" {
  value = aws_instance.web.public_ip
}
```

**SSH into instance (WSL):**
```bash
cp /mnt/c/Users/henri/source/repos/devops-course/class12/terraform/dev-key.pem ~/dev-key.pem
chmod 600 ~/dev-key.pem
ssh -i ~/dev-key.pem ec2-user@$(terraform output -raw public_ip)
```
> ⚠️ `chmod 600` doesn't work on the Windows filesystem — always copy `.pem` to `~/` in WSL first

**Separate state per environment (S3 backend):**
```bash
# Dev
terraform init -backend-config="key=dev/terraform.tfstate" -reconfigure
terraform apply -var-file="environments/dev.tfvars"

# Prod
terraform init -backend-config="key=prod/terraform.tfstate" -reconfigure
terraform apply -var-file="environments/prod.tfvars"
```

**Gotcha — duplicate resource names across environments:**
Any hardcoded name (key pair, security group) collides when both envs run in the same AWS account:
```
Error: InvalidKeyPair.Duplicate: The keypair already exists
```
Fix: prefix all names with `var.environment`:
```hcl
resource "aws_key_pair" "generated" {
  key_name = "${var.environment}-terraform-key"
}
```

**Gotcha — shared state collision:**
Running `terraform apply` for prod after dev (with different subnet CIDRs but shared state) destroys and recreates the subnet + EC2 instance:
```
~ cidr_block = "10.0.1.0/24" -> "10.0.2.0/24"  # forces replacement
```
Real fix: separate VPCs per environment, or separate AWS accounts entirely.
