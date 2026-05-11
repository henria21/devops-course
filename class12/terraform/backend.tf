terraform { 
  backend "s3" { 
    bucket = "terraform-state-student-12345" 
    key = "dev/terraform.tfstate" 
    region = "eu-west-1" 
  } 
}
