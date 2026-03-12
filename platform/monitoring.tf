resource "helm_release" "kube_prometheus_stack" {
name       = "kube-prometheus"
namespace  = kubernetes_namespace_v1.monitoring.metadata[0].name
repository = "https://prometheus-community.github.io/helm-charts"
chart      = "kube-prometheus-stack"
 version    = "55.5.0"

set = [
{
  name  = "grafana.service.type"
  value = "ClusterIP"
},
{
  name  = "prometheus.service.type"
  value = "ClusterIP"
}
]
}