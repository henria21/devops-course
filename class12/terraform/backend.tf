terraform { 
  backend "s3" { 
    bucket = "devops-course-henria21" 
    key = "dev/terraform.tfstate"
    region = "eu-west-1"
  } 
}
