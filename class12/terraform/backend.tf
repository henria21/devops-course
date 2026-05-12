terraform {
  backend "s3" {
    bucket = "devops-course-henria21"
    region = "eu-west-1"
    # key is passed via -backend-config at init time
  }
}
