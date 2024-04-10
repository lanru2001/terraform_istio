######################################################################################
#K8S and Helm Provider
######################################################################################

provider "kubernetes" {
  host                   = ""
  cluster_ca_certificate = base64decode("")
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = [ "eks", "get-token", "--cluster-name", "dlf-dev-eks", "--region",  "us-east-1" ]
    command     = "aws"
  }
}

provider "helm" {
  kubernetes {
    host                   = "https://C4546A3AD320086BBEAF69D3CBEE0CBB.gr7.us-east-1.eks.amazonaws.com"
    cluster_ca_certificate = base64decode("")
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = [ "eks", "get-token", "--cluster-name", "dlf-dev-eks", "--region",  "us-east-1" ]
      command     = "aws"
    }
  }
}

provider "kubectl" {
    host                   = "https://C4546A3AD320086BBEAF69D3CBEE0CBB.gr7.us-east-1.eks.amazonaws.com"
    cluster_ca_certificate = base64decode("")
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = [ "eks", "get-token", "--cluster-name", "dlf-dev-eks", "--region",  "us-east-1" ]
      command     = "aws"
    }
}

provider "aws" {
  region = "us-east-1"
}
