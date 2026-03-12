resource "kubernetes_ingress_v1" "argocd_ingress" {
  metadata {
    name      = "argocd-ingress"
    namespace = "argocd"

    annotations = {
      "nginx.ingress.kubernetes.io/backend-protocol" = "HTTP"
    }
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      host = "argocd.local"

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "argocd-server"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

 
}

resource "kubernetes_ingress_v1" "grafana_ingress" {
  metadata {
    name      = "grafana-ingress"
    namespace = "monitoring"
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      host = "grafana.local"

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "kube-prometheus-grafana"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

 
}

resource "kubernetes_ingress_v1" "prometheus_ingress" {
  metadata {
    name      = "prometheus-ingress"
    namespace = "monitoring"
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      host = "prometheus.local"

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "kube-prometheus-kube-prome-prometheus"
              port {
                number = 9090
              }
            }
          }
        }
      }
    }
  }


}