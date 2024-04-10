# S3 remote state 
# Please do not apply this in Dev until istio route is working in QA
terraform {
  backend "s3" {
    bucket         = "dlframe-tf-remote-dev-bkt"
    key            = "project/dlframe/istio"
    region         = "us-east-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.12"
    }

    kubernetes = {
      source = "hashicorp/kubernetes"
      version = ">= 2.23.0"
    }

    kubectl = {
      source = "gavinbunney/kubectl"
      version = "1.14.0"
    }

    helm = {
      source = "hashicorp/helm"
      version = ">=2.11.0"
    }
  }
}

module "dev_istio" {
    
    source                   = "../../"
    cluster_name             = "dlf-dev-eks"
    istio-ingress            = "istio-ingress"
    open_connect_id          = ""  #id on the OpenID Connect provider URL 
    account_id               = ""
    aws_region               = "us-east-1"
    subnet_ids               = "" # Use the public subnets of the eks private subnets for internet facing ALB
    acm_arn                  = ""
    security_group           = "sg-05165a2afc67fdee1"
    env                      = "dev"
    vpc_id                   = "vpc-91cac0e8 "
    
    #Http2 ports
    service_http2_port       = 80
    service_http2_targetport = 8080
    service_http2_nodeport   = 31032

    #Https ports
    service_https_port       = 443
    service_https_targetport = 8443
    service_https_nodeport   = 31943

    #Healthcheck ports
    healthcheck_port         = 15021
    healthcheck_targetport   = 15021
    healthcheck_nodeport     = 31100
    certificate_authority    = ""
    cluster_endpoint         = ""
}
