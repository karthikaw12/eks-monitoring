resource "kubernetes_namespace_v1" "ingress" {
  metadata { name = "ingress-nginx" }
}

resource "kubernetes_namespace_v1" "argocd" {
  metadata { name = "argocd" }
}

resource "kubernetes_namespace_v1" "monitoring" {
  metadata { name = "monitoring" }
}