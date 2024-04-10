########################################################################################################################################################
#1. Create AWS Load Balancer Controller
#AWS Load Balancer controller manages the Application Load Balancer and Target Group in AWS to satisfy the configuration of Kubernetes ingress objects
########################################################################################################################################################

resource "helm_release" "loadbalancer_controller" {

  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts" 
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  depends_on = [ 
    aws_iam_role.lb_controller_role,
    kubernetes_service_account.service_account,
    #aws_iam_policy.test_policy
  ]

  set {
    name  = "region"
    value = var.aws_region
  }

  set {
    name  = "vpcId"
    value = var.vpc_id
  }

  set {
    name  = "image.repository"
    value = "602401143452.dkr.ecr.us-east-1.amazonaws.com/amazon/aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "rbac.create"
    value = "true"
  }

  set {
    name  = "enableServiceMutatorWebhook"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set {
   name  = "replicaCount"
   value = "1"
  }
  
  #https://github.com/aws/eks-charts/blob/master/stable/aws-load-balancer-controller/values.yaml (affinity)
  set {
    name  = "affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].key"
    value = "poolType"
  }

  set {
    name  = "affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].operator"
    value = "In"
  }

  set {
    name  = "affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].values[0]"
    value = "plugin"
  }

  set {
    name  = "affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchExpressions[0].key"
    value = "app"
  }

  set {
    name  = "affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchExpressions[0].operator"
    value = "In"
  }

  set {
    name  = "affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchExpressions[0].values[0]"
    value = "aws-load-balancer-controller"
  }
 
  set {
    name  = "affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].weight"
    value = "100"
  }

  set {
    name  = "affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.topologyKey"
    value = "kubernetes.io/hostname"
  }
    
}

######################################################################################
#2. Create Service Account for AWS Load Balancer Controller
######################################################################################

resource "kubernetes_service_account" "service_account" {
  depends_on = [ 
       aws_iam_role.lb_controller_role,
       #aws_iam_policy.test_policy
  ]       
  metadata {
    name = "aws-load-balancer-controller"
    namespace = "kube-system"
    labels = {
        "app.kubernetes.io/name" = "aws-load-balancer-controller"
        "app.kubernetes.io/component"= "controller"
    }
    annotations = {
      "eks.amazonaws.com/role-arn" = "${aws_iam_role.lb_controller_role.arn}"
    }
  }
  
}

######################################################################################
#3. Create namespace for istio-system, dlframe and models
######################################################################################

resource "kubernetes_namespace" "istio_system" {
  metadata {
    name = "istio-system"
    labels = {
      istio-injection = "enabled"
      managed         = "true"
    }
  }
}

resource "kubernetes_namespace" "dlframe" {
  metadata {
    name = "dlframe"
    labels = {
      istio-injection = "enabled"
      managed         = "true"
    }
  }
}

resource "kubernetes_namespace" "models" {
  metadata {
    name = "models"
    labels = {
      istio-injection = "enabled"
      managed         = "true"
    }
  }
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
    labels = {
      istio-injection = "enabled"
      managed         = "true"
    }
  }
}

######################################################################################
#4. Install Istio using public repository
######################################################################################
#Source: https://artifacthub.io/packages/helm/avesha/istio-base

resource "helm_release"  "istio_base" {
  name       = "base"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "base"
  namespace  = "istio-system"
  create_namespace = true
  force_update = false
  version      = "1.20.2"

}

#Source: https://artifacthub.io/packages/helm/istio-official/istiod
resource "helm_release"  "istio_istiod" {
  name       = "istiod"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "istiod"
  namespace  = "istio-system"
  create_namespace = true
  force_update = false
  version      = "1.20.2"

  set {
    name  = "meshConfig.accessLogFile"
    value = "/dev/stdout"
  }
  
  #https://artifacthub.io/packages/helm/istio-official/istiod?modal=values (affinity)
  set {
    name  = "affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].key"
    value = "poolType"
  }

  set {
    name  = "affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].operator"
    value = "In"
  }

  set {
    name  = "affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].values[0]"
    value = "plugin"
  }

  set {
    name  = "affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchExpressions[0].key"
    value = "app"
  }

  set {
    name  = "affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchExpressions[0].operator"
    value = "In"

  }

  set {
    name  = "affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchExpressions[0].values[0]"
    value = "istiod"
  }

  set {
    name  = "affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].weight"
    value = "100"
  }
  
}

# ######################################################################################
# #5. Install Istio ingress gateway
# ######################################################################################
#Source: https://artifacthub.io/packages/helm/istio-official/gateway
resource "helm_release" "istio_ingress" {
  name             = "istio-ingressgateway"
  chart            = "gateway"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  namespace        = "istio-system"
  create_namespace = true
  version          = "1.20.2"
  cleanup_on_fail   = true
  force_update      = false
  values = [
  <<-EOT
podAnnotations:
  sidecar.inject.istio.io: "true"
EOT
  ]
  set {
    name  = "service.type"
    value = "NodePort"
  }

  set {
    name  = "autoscaling.minReplicas"
    value = var.istio_ingress_min_pods
  }

  set {
    name  = "autoscaling.maxReplicas"
    value = var.istio_ingress_max_pods
  }

  set {
    name  = "service.ports[0].name"
    value = "status-port"
  }

  set {
    name  = "service.ports[0].port"
    value = var.healthcheck_port
  }

  set {
    name  = "service.ports[0].targetPort"
    value = var.healthcheck_targetport
  }

  set {
    name  = "service.ports[0].nodePort"
    value = var.healthcheck_nodeport
  }

  set {
    name  = "service.ports[0].protocol"
    value = "TCP"
  }

  set {
    name  = "service.ports[1].name"
    value = "http2"
  }

  set {
    name  = "service.ports[1].port"
    value = var.service_http2_port 
  }

  set {
    name  = "service.ports[1].targetPort"
    value = var.service_http2_targetport 
  }

  set {
    name  = "service.ports[1].nodePort"
    value = var.service_http2_nodeport 
  }

  set {
    name  = "service.ports[1].protocol"
    value = "TCP"
  }

  set {
    name  = "service.ports[2].name"
    value = "https"
  }

  set {
    name  = "service.ports[2].port"
    value = var.service_https_port
  }

  set {
    name  = "service.ports[2].targetPort"
    value = var.service_https_targetport
  }

  set {
    name  = "service.ports[2].nodePort"
    value =  var.service_https_nodeport
  }

  set {
    name  = "service.ports[2].protocol"
    value = "TCP"
  }
  
  #https://artifacthub.io/packages/helm/istio-official/gateway?modal=values(affinity)
  set {
    name  = "affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].key"
    value = "poolType"
  }

  set {
    name  = "affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].operator"
    value = "In"
  }

  set {
    name  = "affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].values[0]"
    value = "plugin"
  }

  set {
    name  = "affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchExpressions[0].key"
    value = "app"
  }

  set {
    name  = "affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchExpressions[0].operator"
    value = "In"
  }

  set {
    name  = "affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchExpressions[0].values[0]"
    value = "istio-ingressgateway"
  }

  set {
    name  = "affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].weight"
    value = "100"
  }

  set {
    name  = "affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.topologyKey"
    value = "kubernetes.io/hostname"
  }

  depends_on = [ 
    helm_release.istio_base,
    helm_release.istio_istiod,
    helm_release.metrics_server
  ]
}

######################################################################################
#6. Install istio gateway using kubectl_manifest
######################################################################################

resource "kubectl_manifest" "istio_gateway_dlframe" {
    yaml_body = <<YAML
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: dlframe-gateway
  namespace: dlframe
spec:
  selector:
    istio: ingressgateway
  servers:
  - hosts:
    - "*"
    port:
      name: http
      number: 80
      protocol: HTTP
YAML
    depends_on = [ 
         helm_release.istio_base,
         helm_release.istio_istiod,
         helm_release.istio_ingress      
    ]
}

################################################################
#9. Istio-ingress
################################################################

resource "kubectl_manifest" "ingress" {
    yaml_body = <<YAML
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: "${var.istio-ingress}"
  namespace: istio-system
  annotations:
    alb.ingress.kubernetes.io/actions.ssl-redirect: '{"Type": "redirect", "RedirectConfig":
      { "Protocol": "HTTPS", "Port": "443", "StatusCode": "HTTP_301"}}'
    alb.ingress.kubernetes.io/backend-protocol: HTTP
    alb.ingress.kubernetes.io/certificate-arn: "${var.acm_arn}"
    alb.ingress.kubernetes.io/healthcheck-path: "/healthz/ready"
    alb.ingress.kubernetes.io/healthcheck-port: "${var.healthcheck_nodeport}"
    alb.ingress.kubernetes.io/healthcheck-interval-seconds: '200'
    alb.ingress.kubernetes.io/healthcheck-timeout-seconds: '100'
    alb.ingress.kubernetes.io/healthcheck-protocol: HTTP
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}, {"HTTPS":443}]'
    alb.ingress.kubernetes.io/target-type: instance
    alb.ingress.kubernetes.io/subnets: "${var.subnet_ids}"
    alb.ingress.kubernetes.io/security-groups: "${var.security_group}"
    alb.ingress.kubernetes.io/scheme: internet-facing
    kubernetes.io/ingress.class: alb
spec:
  rules:
  - http:
      paths:
      - backend:
          service:
            name: ssl-redirect
            port:
              name: use-annotation
        path: /
        pathType: Prefix
      - backend:
          service:
            name: istio-ingressgateway
            port:
              number: 80
        path: /
        pathType: Prefix
YAML
    depends_on = [ 
        helm_release.istio_base,
        helm_release.istio_istiod,
        helm_release.loadbalancer_controller,
        kubectl_manifest.istio_gateway_dlframe,
        aws_iam_role.lb_controller_role,
        kubernetes_service_account.service_account,
    ]
}
