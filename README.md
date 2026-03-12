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
 - Secure secrets and config with Kubernetes RBAC and pod security policies.
 - Expand storage with additional StorageClasses as needed.

## License
Specify your license here.

---
*Generated on March 12, 2026.*