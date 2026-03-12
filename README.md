# EKS Project Overview

This repository is structured to provision and manage an AWS EKS cluster, deploy core infrastructure, and run applications using Kubernetes and Terraform.

## Folder Structure

  - Contains Terraform code for AWS infrastructure provisioning.
  - Key files:
    - `eks.tf`: Provisions EKS cluster using terraform-aws-modules/eks.
    - `vpc.tf`: Creates VPC and subnets using terraform-aws-modules/vpc.
    - Other files: Providers, outputs, variables, and state management.
  - Main modules:
    - EKS cluster (with managed node groups, IRSA, cluster addons)
    - VPC (with NAT gateway, public/private subnets)
    - IAM role for EBS CSI driver
  - Key variables:
    - `region`, `cluster_name`, `node_instance_type`
  - Outputs:
    - `cluster_name`, `cluster_endpoint`, `cluster_ca`

  - Manages platform-level services via Terraform Helm releases.
  - Key files:
    - `argocd.tf`: Installs ArgoCD for GitOps workflows.
    - `monitoring.tf`: Installs Prometheus/Grafana stack for monitoring.
    - Other files: Ingress, namespace, and provider configuration.
  - Helm releases:
    - ArgoCD (GitOps)
    - Kube Prometheus Stack (Prometheus, Grafana)
  - Ingress rules for ArgoCD, Grafana, Prometheus
  - Namespaces: ingress-nginx, argocd, monitoring
  - Providers: AWS, Kubernetes, Helm (with remote state)

  - Contains Kubernetes manifests for application and service deployment.
  - Subfolders:
    - `backend/`: Backend deployment, HPA, service, and monitoring.
    - `frontend/`: Frontend deployment and service.
    - `database/`: PostgreSQL StatefulSet and service.
    - `config/`: ConfigMap and Secret definitions.
    - `monitoring/`: Dashboards, Prometheus rules, ServiceMonitors.
    - `namespace/`: Namespace manifest.
    - `storage/`: StorageClass manifest.
  - Example environment variables (from ConfigMap/Secret):
    - `DB_HOST`, `DB_USER`, `DB_NAME`, `AWS_REGION`, `SES_FROM_EMAIL`, `SNS_ENABLED`, `POSTGRES_PASSWORD`, `JWT_SECRET`
  - Monitoring:
    - Grafana dashboards for backend and cluster health
    - Prometheus rules for backend status, CPU usage, pod restarts
    - ServiceMonitors for backend and ArgoCD metrics
  - Storage:
    - StorageClass (EBS CSI, gp3, volume expansion)
  - Namespace:
    - `otp-prod` (with pod security enforcement)

## Usage

1. **Provision Infrastructure**
   - Navigate to `infra/` and run Terraform commands to create VPC and EKS cluster.
2. **Install Platform Services**
   - Use Terraform in `platform/` to deploy ArgoCD and monitoring stack.
3. **Deploy Applications**
   - Apply Kubernetes manifests from `k8s/` using `kubectl` or ArgoCD.
 4. **Access Platform Services**
   - Use provided ingress rules to access ArgoCD (`argocd.local`), Grafana (`grafana.local`), and Prometheus (`prometheus.local`).
   - Update your `/etc/hosts` or DNS as needed for local access.

## Requirements
- Terraform
- AWS credentials
- kubectl
 - Helm (for platform services)
 - NGINX Ingress Controller (for platform ingress)

## Example Workflow
```bash
cd infra
terraform init
terraform apply

cd ../platform
terraform init
terraform apply

kubectl apply -f k8s/
```
 # Advanced Usage
 - Customize node group instance types and sizes in `infra/eks.tf`.
 - Add new Helm releases in `platform/` for additional services.
 - Extend monitoring with custom dashboards and Prometheus rules in `k8s/monitoring/`.

## Monitoring: Scenarios & Solutions
### Additional Monitoring Scenarios

- **Pod Stuck Terminating**
  - Symptom: Pod does not terminate, remains in Terminating state.
  - Solution: Run `kubectl delete pod <pod> --grace-period=0 --force -n otp-prod`. Check for finalizers or volume detach issues.

- **Prometheus Target Down**
  - Symptom: Prometheus UI shows target as down.
  - Solution: Check ServiceMonitor selector and pod labels. Run `kubectl get endpoints -n <namespace>` to verify target port. Review pod logs for readiness issues.

- **Grafana Login Issues**
  - Symptom: Cannot log in to Grafana UI.
  - Solution: Reset admin password via Kubernetes secret or Helm values. Check ingress and service configuration.

- **Ingress TLS/SSL Issues**
  - Symptom: HTTPS not working, certificate errors.
  - Solution: Check ingress TLS configuration, certificate secret, and NGINX controller logs. Validate certificate format and domain.

- **Pod Affinity/Anti-Affinity Issues**
  - Symptom: Pods not scheduled as expected.
  - Solution: Review affinity/anti-affinity rules in deployment YAML. Check node labels and available resources.

- **Resource Quota Exceeded**
  - Symptom: New pods fail to start, quota errors.
  - Solution: Run `kubectl describe quota -n otp-prod` to check quota usage. Adjust quota or optimize resource usage.

- **Service Not Resolving DNS**
  - Symptom: Pods cannot resolve service DNS names.
  - Solution: Check CoreDNS pod status and logs. Review service and pod DNS policies. Restart CoreDNS if needed.

- **PVC Not Bound**
  - Symptom: Database or application pods stuck pending.
  - Solution: Run `kubectl get pvc -n otp-prod` to check PVC status. Ensure StorageClass exists and is referenced correctly. Check EBS CSI driver logs.

- **Pod Network Issues**
  - Symptom: Services can't communicate, DNS failures.
  - Solution: Run `kubectl exec <pod> -n otp-prod -- nslookup <service>` to test DNS. Check CNI plugin status and logs. Review network policies.

- **Prometheus Not Alerting**
  - Symptom: Expected alerts not firing.
  - Solution: Check PrometheusRule syntax and reload status. Review alert expression and thresholds. Use Prometheus UI to test alert queries.

- **Grafana Dashboard Import Fails**
  - Symptom: Unable to import custom dashboards.
  - Solution: Check JSON syntax, panel limits, and Grafana version compatibility. Review Grafana logs for errors.

- **Pod Image Pull Errors**
  - Symptom: Pods stuck in ImagePullBackOff.
  - Solution: Run `kubectl describe pod <pod> -n otp-prod` for error details. Check image name, tag, and registry credentials.

- **Secret/ConfigMap Not Mounted**
  - Symptom: Application errors due to missing env/config.
  - Solution: Run `kubectl describe pod <pod> -n otp-prod` and check volume mounts. Verify secret/configmap exists and is referenced correctly.

- **Prometheus Data Retention Issues**
  - Symptom: Metrics missing after restart or over time.
  - Solution: Check Prometheus PVC and retention settings. Ensure persistent storage is configured and healthy.

- **Pod Scheduling Failures**
  - Symptom: Pods stuck in Pending state.
  - Solution: Run `kubectl describe pod <pod> -n otp-prod` for scheduling events. Check node taints, tolerations, and resource requests.

### Common Monitoring Scenarios
1. **Backend Service Down**
  - Alert: `OTPBackendDown`
  - Solution: Check backend pod status, logs, and service endpoints. Restart pods if needed.

2. **High CPU Usage**
  - Alert: `HighCPUUsage`
  - Solution: Scale up pods, optimize application code, or increase node resources.

3. **Pod CrashLoop**
  - Alert: `PodCrashLoop`
  - Solution: Inspect pod logs for errors, check environment variables and secrets, fix application bugs.

4. **Database Unreachable**
  - Symptom: Backend errors, failed DB connections.
  - Solution: Check database StatefulSet, service, and PVC status. Ensure secrets/configs are correct.

5. **Missing Metrics in Grafana**
  - Symptom: Dashboards show gaps or no data.
  - Solution: Verify ServiceMonitor configuration, Prometheus targets, and pod annotations.

6. **Ingress Not Accessible**
  - Symptom: Cannot access Grafana, Prometheus, or ArgoCD via ingress URLs.
  - Solution: Check ingress rules, NGINX controller status, and DNS/hosts configuration.

### Troubleshooting Steps
- **Backend Service Down**
  1. Run `kubectl get pods -n otp-prod` and check pod status.
  2. Run `kubectl describe pod <backend-pod> -n otp-prod` for events and errors.
  3. Run `kubectl logs <backend-pod> -n otp-prod` for application logs.
  4. Check `kubectl get svc -n otp-prod` for service endpoints.
  5. Restart pod: `kubectl delete pod <backend-pod> -n otp-prod`.

- **High CPU Usage**
  1. Review Grafana dashboard for CPU metrics.
  2. Run `kubectl top pods -n otp-prod` to check pod resource usage.
  3. Scale up pods: `kubectl scale deployment backend -n otp-prod --replicas=3`.
  4. Increase node group size in Terraform and re-apply.

- **Pod CrashLoop**
  1. Run `kubectl get pods -n otp-prod` and look for CrashLoopBackOff.
  2. Run `kubectl logs <crashing-pod> -n otp-prod` for error details.
  3. Check environment variables and secrets: `kubectl describe pod <crashing-pod> -n otp-prod`.
  4. Fix application bug and redeploy.

- **Database Unreachable**
  1. Run `kubectl get pods -n otp-prod` and check database pod status.
  2. Run `kubectl get pvc -n otp-prod` to check storage.
  3. Run `kubectl logs <db-pod> -n otp-prod` for connection errors.
  4. Check secret and configmap values.

- **Missing Metrics in Grafana**
  1. Open Prometheus UI and check targets for backend and argocd.
  2. Run `kubectl get servicemonitor -A` to verify ServiceMonitor resources.
  3. Check pod annotations and ports.

- **Ingress Not Accessible**
  1. Run `kubectl get ingress -A` to check ingress status.
  2. Run `kubectl describe ingress <name> -n <namespace>` for events.
  3. Check NGINX ingress controller pod status.
  4. Verify DNS or `/etc/hosts` entries for local access.

- **Node Disk Pressure**
  1. Run `kubectl describe node <node>` and check for disk pressure warnings.
  2. Clean up unused pods, PVCs, and images.
  3. Add more storage or new nodes if needed.

- **ServiceMonitor Not Scraping**
  1. Check ServiceMonitor labels and selector match.
  2. Run `kubectl get endpoints -n <namespace>` to verify target pod ports.
  3. Check Prometheus UI for scrape errors.

- **Alert Fatigue**
  1. Tune alert thresholds in PrometheusRule.
  2. Group related alerts and use severity labels.
  3. Silence non-critical alerts in Prometheus UI.

- **Slow Application Response**
  1. Review Grafana dashboard for latency metrics.
  2. Run `kubectl top pods -n otp-prod` for resource usage.
  3. Profile application and optimize code.
  4. Scale pods or increase resources as needed.

- **Pod Resource Limits Hit**
  1. Run `kubectl describe pod <pod> -n otp-prod` and check for OOMKilled or throttling.
  2. Adjust resource requests/limits in deployment YAML.
  3. Monitor usage trends and optimize application.
 - Secure secrets and config with Kubernetes RBAC and pod security policies.
 - Expand storage with additional StorageClasses as needed.

## License
Specify your license here.

---
*Generated on March 12, 2026.*