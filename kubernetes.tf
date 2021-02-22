terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_deployment" "flask" {
  metadata {
    name = "flask"
    labels = {
      App = "flask"
    }
  }

  spec {
    replicas = 2
    selector {
      match_labels = {
        App = "flask"
      }
    }
    template {
      metadata {
        labels = {
          App = "flask"
        }
      }
      spec {
        container {
          image = "willstopher/case-study-1:latest"
          name  = "flask"

          port {
            container_port = 5000
          }

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "128Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "flask-service" {
  metadata {
    name = "flask-service"
  }
  spec {
    selector = {
      App = kubernetes_deployment.flask.spec.0.template.0.metadata[0].labels.App
    }
    port {
      node_port   = 30201
      port        = 5000
      target_port = 5000
    }

    type = "NodePort"
  }
}
