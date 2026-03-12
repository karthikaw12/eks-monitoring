resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = kubernetes_namespace_v1.argocd.metadata[0].name
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "5.51.6"

  set = [
    {
      name  = "server.service.type"
      value = "ClusterIP"
    },
    {
      name  = "server.extraArgs[0]"
      value = "--insecure"
    }
  ]
}