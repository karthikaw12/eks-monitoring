
resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  namespace  = kubernetes_namespace_v1.ingress.metadata[0].name
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.10.0"

  set = [
    {
      name  = "controller.service.type"
      value = "LoadBalancer"
    }
  ]
}