provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
}


resource "kubernetes_namespace" "kav_ns" {
  metadata {
    name = "nginx"
  }
}
resource "kubernetes_deployment" "kav_deply" {
  metadata {
    name      = "nginx"
    namespace = kubernetes_namespace.kav_ns.metadata.0.name
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "kav_app"
      }
    }
    template {
      metadata {
        labels = {
          app = "kav_app"
        }
      }
      spec {
        container {
          image = "nginx"
          name  = "nginx-container"
          port {
            container_port = 80
          }
        }
      }
    }
  }
}
resource "kubernetes_service" "kav_svc" {
  metadata {
    name      = "nginx"
    namespace = kubernetes_namespace.kav_ns.metadata.0.name
  }
  spec {
    selector = {
      app = kubernetes_deployment.kav_deply.spec.0.template.0.metadata.0.labels.app
    }
    type = "LoadBalancer"
    port {
      port        = 80
      target_port = 80
    }
  }
}