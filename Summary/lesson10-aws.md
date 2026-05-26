# Lesson 10 — AWS (Amazon Web Services)
> Source: `Class 10 - AWS.pptx` (26 slides)

---

## What is AWS?

AWS is a **cloud platform** that allows companies to run applications without owning physical servers.
- Instead of buying hardware → **rent infrastructure on demand**
- Pay-as-you-go pricing
- Global infrastructure with high availability
- Automatic scaling

### Why Companies Use AWS
- No hardware management
- Global infrastructure across regions and availability zones
- High availability and fault tolerance
- Disaster recovery built in

---

## AWS Global Infrastructure

```
Region (e.g., us-east-1)
  ├── Availability Zone 1
  ├── Availability Zone 2
  └── Availability Zone 3
```

Each AZ = one or more physical data centers.
Deploying across AZs provides **fault tolerance** and **disaster recovery**.

---

## Core AWS Services

| Service | Category | Description |
|---|---|---|
| **EC2** | Compute | Virtual servers in the cloud |
| **S3** | Storage | Object storage for files, backups, static sites |
| **VPC** | Networking | Private network inside AWS |
| **IAM** | Security | Identity and access management |
| **CloudWatch** | Monitoring | Metrics, logs, and alarms |

---

## EC2 — Elastic Compute Cloud

Virtual servers (instances) in the cloud:
- Choose instance type (CPU, RAM, storage)
- Launch from an AMI (Amazon Machine Image)
- Connect via SSH
- Install web servers, databases, applications

### Typical EC2 workflow
1. Launch EC2 instance from the console
2. Connect via SSH: `ssh -i key.pem ubuntu@<public-ip>`
3. Install web server (e.g., nginx, Apache)

---

## S3 — Simple Storage Service

Highly scalable **object storage** service:
- Stores data as **objects inside buckets**
- **Typical use cases:**
  - Storing images and videos
  - Application backups
  - Log storage
  - Static website hosting
  - Data lakes
- Free tier: **5 GB storage**

---

## VPC — Virtual Private Cloud

Allows you to create a **private network inside AWS** — like a virtual data center.

### VPC Components

#### Subnets
Smaller networks inside a VPC to organize infrastructure:
| Type | Description |
|---|---|
| **Public subnet** | Connected to internet — hosts web servers |
| **Private subnet** | No direct internet access — hosts databases |

#### Internet Gateway
Connects the VPC to the internet.
```
User → Internet → Internet Gateway → EC2 Web Server
```
Resources in **public subnets** route through the Internet Gateway.

#### Route Tables
Control where network traffic goes:
| Destination | Target |
|---|---|
| `0.0.0.0/0` | Internet Gateway (public traffic) |
| `10.0.0.0/16` | Local (VPC internal traffic) |

Route tables determine whether a subnet is **public or private**.

#### Security Groups
Virtual firewalls controlling inbound and outbound traffic to instances.
- Define allowed ports and protocols
- Applied at the instance level

---

## IAM — Identity and Access Management

Controls **who can access AWS resources** and **what they are allowed to do**.

### IAM Components
| Component | Description |
|---|---|
| **Users** | Individual accounts for people |
| **Groups** | Collections of users with shared permissions |
| **Roles** | Identities assumed by services or applications |
| **Policies** | JSON documents defining permissions |

### IAM Policy Structure
```json
{
  "Effect": "Allow",
  "Action": "s3:ListBucket",
  "Resource": "*"
}
```

### IAM Best Practices
- ❌ Never use root account for daily work
- ✅ Enable Multi-Factor Authentication (MFA)
- ✅ Grant **least privilege** permissions
- ✅ Rotate credentials regularly
- ✅ Use **roles** instead of static access keys
- ✅ Avoid embedded access keys in code

### IAM Security Risks
Misconfigured IAM is one of the most common cloud security issues:
- Exposed access keys
- Excessive permissions
- Unauthorized infrastructure changes
- Unexpected cloud costs

---

## CloudWatch — Monitoring

Collects metrics and logs from AWS resources:
- CPU usage, network traffic, disk activity
- Application logs
- Custom alarms and dashboards

Critical for DevOps and production reliability.

---

## AWS CLI

Manage AWS services **from the command line** instead of the web console.

### Why DevOps engineers use CLI
- Faster than manual console operations
- Enables automation and scripting
- Integrates with CI/CD pipelines

### Configuration
```bash
aws configure
# Prompts for:
# - Access Key ID
# - Secret Access Key
# - Default region (e.g., us-east-1)
# - Output format (json/table/text)
```

### Common CLI commands
```bash
aws ec2 describe-instances           # List EC2 instances
aws s3 ls                            # List S3 buckets
aws s3 cp file.txt s3://my-bucket/   # Upload to S3
aws iam list-users                   # List IAM users
```

---

## AWS Free Tier

AWS offers a free tier for exploring services:
- EC2: 750 hours/month of t2.micro or t3.micro
- S3: 5 GB storage
- CloudWatch: Basic monitoring
- IAM: Always free

**Cost management best practices:**
- Stop unused resources immediately
- Monitor usage regularly
- Stay within free tier limits
- Review billing dashboard regularly
- Use **AWS Cost Explorer** to analyze spending

---

## Key Takeaways

1. AWS = rent infrastructure on demand — no hardware ownership
2. **EC2** = virtual servers; **S3** = object storage; **VPC** = private network; **IAM** = access control
3. VPC networking: subnets (public/private) + Internet Gateway + route tables + security groups
4. **IAM** controls all access — always use least privilege and avoid the root account
5. **AWS CLI** is essential for DevOps automation — integrates into CI/CD pipelines
6. Always monitor costs — set billing alerts and stop unused resources

---

## Assignment

**Goal:** Complete the AWS Free Tier Hands-On Lab — learn to create and manage AWS resources using both the Console and CLI.

**Estimated Time:** 3–4 hours | **Prerequisites:** AWS account, AWS CLI v2, basic terminal knowledge

**Parts:**
1. **IAM** — Create `student-user`, enable console access, attach `AdministratorAccess`, activate MFA; CLI: `aws configure`, `sts get-caller-identity`, `iam create-user`, `iam list-users`
2. **S3** — Create bucket `aws-lab-yourname`, upload `hello.txt`; CLI: `aws s3 mb`, `aws s3 cp`, `aws s3 ls`, `s3api put-object-acl`
3. **EC2** — Launch `t2.micro` Amazon Linux instance, create key pair, connect via EC2 Instance Connect, install Apache web server; CLI: `ec2 run-instances`, `ec2 describe-instances`, `ec2 stop-instances`
4. **VPC** — Explore default VPC; optionally create `lab-vpc` (`10.0.0.0/16`) and `lab-subnet` (`10.0.1.0/24`); CLI: `ec2 create-vpc`, `ec2 create-subnet`
5. **Lambda** — Create Python function returning `Hello from AWS Lambda!`; CLI: create IAM role, zip & deploy function, `lambda invoke`
6. **CloudWatch** — Create log group and stream, push and read log events; CLI: `logs create-log-group`, `logs put-log-events`, `logs get-log-events`
7. **Cleanup** — Terminate all resources to stay within Free Tier limits

**Free Tier Limits:**
| Service | Free Limit |
|---|---|
| EC2 | 750 hours/month (t2.micro) |
| S3 | 5 GB storage, 20k GET, 2k PUT |
| Lambda | 1M requests/month, 400k GB-seconds |
| CloudWatch | 5 GB log ingestion, 10 custom metrics |

**Optional Bonus:** Build serverless app — S3 static site → Lambda (Function URL) → DynamoDB visit counter

---

## Student Answers

**IAM Setup:**
```bash
aws configure
# Region: eu-north-1, Output: json

aws sts get-caller-identity
# { "UserId": "...", "Account": "ACCOUNT-ID", "Arn": "arn:aws:iam::ACCOUNT-ID:user/henria21user" }

aws iam create-user --user-name cli-test-user
aws iam list-users
```

**S3 Operations:**
```bash
aws s3 mb s3://aws-cli-lab-henria
aws s3 cp hello.txt s3://aws-cli-lab-henria/
aws s3 ls s3://aws-cli-lab-henria/

# Make object public (must disable Block Public Access first)
aws s3api put-public-access-block --bucket aws-cli-lab-henria \
  --public-access-block-configuration "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false"
aws s3api put-object-acl --bucket aws-cli-lab-henria --key hello.txt --acl public-read
```
> ⚠️ `put-object-acl` fails if Block Public Access is enabled — disable it first.

**EC2 Launch:**
```bash
# Find correct AMI for eu-north-1
aws ec2 describe-images --owners amazon \
  --filters "Name=name,Values=al2023-ami-2023*" "Name=architecture,Values=x86_64" \
  --query "sort_by(Images, &CreationDate)[-1].[ImageId,Name]" \
  --output table --region eu-north-1
# ami-08c1762b0f609d3b9

aws ec2 run-instances --image-id ami-08c1762b0f609d3b9 --count 1 \
  --instance-type t3.micro --key-name webserver-key-pair \
  --security-group-ids sg-086b11687928c1f35 --subnet-id subnet-00180f903beaa92e6
```

**Apache web server (installed via EC2 Instance Connect):**
```bash
sudo dnf update -y && sudo dnf install -y httpd
sudo systemctl start httpd && sudo systemctl enable httpd
echo "<h1>Hello from EC2!</h1>" | sudo tee /var/www/html/index.html
```

**VPC:**
```bash
aws ec2 create-vpc --cidr-block 10.0.0.0/16 --region eu-north-1
aws ec2 create-tags --resources vpc-0b1e73f245298d229 --tags Key=Name,Value=lab-vpc
aws ec2 create-subnet --vpc-id vpc-0b1e73f245298d229 --cidr-block 10.0.1.0/24 \
  --availability-zone eu-north-1c
```

**Lambda:**
```python
# lambda_function.py
def lambda_handler(event, context):
    return {'statusCode': 200, 'body': 'Hello from AWS Lambda!'}
```
```powershell
Compress-Archive -Path lambda_function.py -DestinationPath function.zip
aws lambda create-function --function-name hello-cli-lambda --runtime python3.14 \
  --role arn:aws:iam::ACCOUNT-ID:role/lambda-cli-role \
  --handler lambda_function.lambda_handler --zip-file fileb://function.zip
aws lambda invoke --function-name hello-cli-lambda output.txt
# output.txt: {"statusCode": 200, "body": "Hello from AWS Lambda!"}
```

**CloudWatch:**
```bash
aws logs create-log-group --log-group-name lab-log-group-cli
aws logs create-log-stream --log-group-name lab-log-group-cli --log-stream-name lab-stream
aws logs get-log-events --log-group-name lab-log-group-cli --log-stream-name lab-stream
```

**Optional Bonus — Serverless App:**
```
Architecture: User → S3 Static Website → Lambda (Function URL) → DynamoDB
```
```python
import json, boto3, uuid
from datetime import datetime

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('lab-visits')

def lambda_handler(event, context):
    table.put_item(Item={'id': str(uuid.uuid4()), 'timestamp': datetime.utcnow().isoformat(), 'message': 'User visited!'})
    count = table.scan()['Count']
    return {'statusCode': 200, 'headers': {'Access-Control-Allow-Origin': '*'},
            'body': json.dumps({'message': 'Hello from Lambda!', 'total_visits': count})}
```
