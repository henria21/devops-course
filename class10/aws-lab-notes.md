# AWS Lab Notes

---

## 5. IAM – Console + CLI

```bash
aws configure
# AWS Access Key ID: [REDACTED]
# AWS Secret Access Key: [REDACTED]
# Default region name: eu-north-1
# Default output format: json
```

```powershell
# Clear credentials in PowerShell
$env:AWS_ACCESS_KEY_ID=$null; $env:AWS_SECRET_ACCESS_KEY=$null; $env:AWS_SESSION_TOKEN=$null
```

```bash
aws sts get-caller-identity
```
```json
{
    "UserId": "AIDA4JXGJDDV6FDFHU3N5",
    "Account": "ACCOUNT-ID",
    "Arn": "arn:aws:iam::ACCOUNT-ID:user/henria21user"
}
```

```bash
# Get session token with MFA
aws sts get-session-token --serial-number arn:aws:iam::ACCOUNT-ID:mfa/henria21user --token-code <MFA-CODE>

# Create a test user
aws iam create-user --user-name cli-test-user

# List all users
aws iam list-users
```

---

## 6. S3 – Console + CLI

```bash
# Create bucket
aws s3 mb s3://aws-cli-lab-henria

# Upload file
aws s3 cp hello.txt s3://aws-cli-lab-henria/

# List bucket contents
aws s3 ls s3://aws-cli-lab-henria/
```

```bash
# Make object public (requires disabling Block Public Access first)
aws s3api put-public-access-block --bucket aws-cli-lab-henria \
  --public-access-block-configuration "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false"

aws s3api put-object-acl --bucket aws-cli-lab-henria --key hello.txt --acl public-read
```

**Note:** `put-object-acl` fails if Block Public Access (BPA) is enabled at the bucket level — disable it first with `put-public-access-block`.

---

## 7. EC2 – Console + CLI

```bash
# Find correct AMI for eu-north-1
aws ec2 describe-images --owners amazon \
  --filters "Name=name,Values=al2023-ami-2023*" "Name=architecture,Values=x86_64" "Name=virtualization-type,Values=hvm" \
  --query "sort_by(Images, &CreationDate)[-1].[ImageId,Name]" \
  --output table --region eu-north-1
# Result: ami-08c1762b0f609d3b9 | al2023-ami-2023.10.20260302.1-kernel-6.12-x86_64

# Launch instance
aws ec2 run-instances --image-id ami-08c1762b0f609d3b9 --count 1 --instance-type t3.micro --key-name webserver-key-pair --security-group-ids sg-086b11687928c1f35 --subnet-id subnet-00180f903beaa92e6 --region eu-north-1

# Connect via SSH
ssh -i ~/Downloads/webserver-key-pair.pem ec2-user@<PUBLIC-IP>
```

**Apache web server (on EC2 via EC2 Instance Connect):**
```bash
sudo dnf update -y
sudo dnf install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd
echo "<h1>Hello from EC2!</h1>" | sudo tee /var/www/html/index.html

# Check status
sudo systemctl status httpd
```

```bash
# Stop instances
aws ec2 stop-instances --instance-ids i-03cb63f0241660f8e i-0fb205ac6d0a67f02

# Terminate instances
aws ec2 terminate-instances --instance-ids i-03cb63f0241660f8e i-0fb205ac6d0a67f02
```

---

## 8. VPC – Console + CLI

```bash
# Create lab VPC
aws ec2 create-vpc --cidr-block 10.0.0.0/16 --region eu-north-1

# Tag it
aws ec2 create-tags --resources vpc-0b1e73f245298d229 --tags Key=Name,Value=lab-vpc --region eu-north-1

# Create subnet
aws ec2 create-subnet --vpc-id vpc-0b1e73f245298d229 --cidr-block 10.0.1.0/24 --availability-zone eu-north-1c --region eu-north-1

# List all VPCs
aws ec2 describe-vpcs --region eu-north-1
```

**Default VPC:** `vpc-096a51e1ccc4e66c8` | `172.31.0.0/16`  
**Lab VPC:** `vpc-0b1e73f245298d229` | `10.0.0.0/16`

**Default subnets:**
| Subnet ID | CIDR | AZ |
|---|---|---|
| subnet-00180f903beaa92e6 | 172.31.16.0/20 | eu-north-1a |
| subnet-0a0896e5bc2308d7a | 172.31.32.0/20 | eu-north-1b |
| subnet-03291a357c6d821db | 172.31.0.0/20  | eu-north-1c |

**Lab subnet:** `subnet-0430534fb0a39b786` | `10.0.1.0/24` | eu-north-1c

---

## 9. Lambda – Console + CLI

```bash
# Create IAM role for Lambda
aws iam create-role --role-name lambda-cli-role --assume-role-policy-document file://trust-policy.json

# Attach policy
aws iam attach-role-policy --role-name lambda-cli-role --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
```

**trust-policy.json:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "Service": "lambda.amazonaws.com" },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

**lambda_function.py:**
```python
def lambda_handler(event, context):
    return {
        'statusCode': 200,
        'body': 'Hello from AWS Lambda!'
    }
```

```powershell
# Zip the function (PowerShell)
Compress-Archive -Path lambda_function.py -DestinationPath function.zip

# Deploy function
aws lambda create-function --function-name hello-cli-lambda --runtime python3.14 --role arn:aws:iam::ACCOUNT-ID:role/lambda-cli-role --handler lambda_function.lambda_handler --zip-file fileb://function.zip --region eu-north-1

# Invoke function
aws lambda invoke --function-name hello-cli-lambda output.txt --region eu-north-1
# output.txt: {"statusCode": 200, "body": "Hello from AWS Lambda!"}
```

---

## 10. CloudWatch – Console + CLI

```bash
# Create log group and stream
aws logs create-log-group --log-group-name lab-log-group-cli --region eu-north-1
aws logs create-log-stream --log-group-name lab-log-group-cli --log-stream-name lab-stream --region eu-north-1
```

```powershell
# Push log event (PowerShell - write to file first to avoid encoding issues)
'[{"timestamp":' + [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds() + ',"message":"Hello CloudWatch CLI"}]' | Out-File -FilePath events.json -Encoding ascii

aws logs put-log-events --log-group-name lab-log-group-cli --log-stream-name lab-stream --log-events file://events.json --region eu-north-1
```

```bash
# Read log events
aws logs get-log-events --log-group-name lab-log-group-cli --log-stream-name lab-stream --region eu-north-1
```

---

## 12. Optional Challenge – Serverless App

**Architecture:** User → S3 Static Website → Lambda (Function URL) → DynamoDB

**Lambda function (Python):**
```python
import json
import boto3
import uuid
from datetime import datetime

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('lab-visits')

def lambda_handler(event, context):
    table.put_item(Item={
        'id': str(uuid.uuid4()),
        'timestamp': datetime.utcnow().isoformat(),
        'message': 'User visited!'
    })
    response = table.scan()
    count = response['Count']
    return {
        'statusCode': 200,
        'headers': {'Access-Control-Allow-Origin': '*'},
        'body': json.dumps({
            'message': 'Hello from Lambda!',
            'total_visits': count
        })
    }
```

**Cleanup:**
```bash
aws s3 rm s3://lab-serverless-site-henria --recursive --region eu-north-1
aws s3 rb s3://lab-serverless-site-henria --region eu-north-1
aws lambda delete-function --function-name lab-serverless-fn --region eu-north-1
aws dynamodb delete-table --table-name lab-visits --region eu-north-1
aws iam detach-role-policy --role-name lambda-cli-role --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
aws iam detach-role-policy --role-name lambda-cli-role --policy-arn arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess
aws iam delete-role --role-name lambda-cli-role
```
