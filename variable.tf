variable "cluster_name" {}

variable "certificate_authority" {}

variable "cluster_endpoint" {} 

variable "open_connect_id" {}

variable "vpc_id" {}

variable "istio_ingress_min_pods" {
  type        = number
  default     = 1
  description = "Minimum pods for istio-ingress-gateway"
}

variable "istio_ingress_max_pods" {
  type        = number
  default     = 1
  description = "Maximum pods for istio-ingress-gateway"
}

variable "aws_region" {}

variable "account_id" {}

variable "subnet_ids" {}

variable "acm_arn" {}

variable "security_group" {}

variable "env" {}

variable "istio-ingress" {}


#Http2 ports
variable "service_http2_port" {}
variable "service_http2_targetport" {}
variable "service_http2_nodeport" {}

#Https ports
variable "service_https_port" {}
variable "service_https_targetport" {}
variable "service_https_nodeport" {}

#Healthcheck ports
variable "healthcheck_port" {}
variable "healthcheck_targetport" {}
variable "healthcheck_nodeport" {}
