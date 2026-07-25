# Monitoring Stack on AWS — Fully Automated

Deploy a demo app with **Prometheus** and **Grafana** on AWS with **one command**. No manual key pairs, no config files, no Docker locally.

## One-command deploy

```powershell
cd "d:\animioui\Grafana\New folder"
.\deploy.ps1
```

That's it. The script automatically:

1. Initializes Terraform
2. Detects your public IP and restricts access to it
3. Creates an SSH key pair and saves it to `terraform/keys/`
4. Provisions EC2, S3, security groups, and Elastic IP on AWS
5. Bootstraps Docker, Prometheus, Grafana, and the demo app on EC2
6. Waits until all services are healthy
7. Opens Grafana in your browser

**Grafana login:** `admin` / `admin123`  
**Dashboard:** Dashboards → Demo App Monitoring

## One-command destroy

```powershell
.\destroy.ps1
```

Removes all AWS resources automatically (no prompts).

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.5
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) configured (`aws configure`)
- PowerShell 5.1+

## What gets automated

| Step | Manual before | Automated now |
|------|---------------|---------------|
| SSH key pair | Create in AWS Console | Auto-generated |
| Security rules | Set CIDR manually | Auto-detects your IP |
| EC2 bootstrap | Wait and hope | Health-check wait built in |
| Grafana setup | Manual datasource/dashboard | Pre-provisioned |
| Traffic/metrics | Manual curls | Auto-generated on EC2 |
| Deploy | Multiple terraform commands | Single `deploy.ps1` |

## Architecture

```
deploy.ps1 → Terraform → AWS
                          ├── EC2 (app + Prometheus + Grafana)
                          ├── S3 (configs)
                          ├── Security Group (your IP only)
                          ├── Elastic IP
                          └── SSH Key Pair (auto-created)
```

## URLs after deploy

```powershell
cd terraform
terraform output grafana_url
terraform output prometheus_url
terraform output demo_app_url
terraform output deployment_summary
```

## SSH (automatic)

```powershell
terraform output -raw ssh_command
```

Private key is saved at `terraform/keys/monitoring-demo.pem`.

## Optional customization

Copy `terraform/terraform.tfvars.example` to `terraform/terraform.tfvars` and edit:

```hcl
aws_region             = "us-east-1"
auto_detect_ip         = false
allowed_cidr           = "0.0.0.0/0"
auto_generate_ssh_key  = true
```

## Troubleshooting

**Services not ready?** The deploy script waits up to 10 minutes. Check EC2 logs:

```powershell
ssh -i terraform/keys/monitoring-demo.pem ec2-user@YOUR_IP
sudo tail -f /var/log/user-data.log
docker compose -f /opt/monitoring/docker-compose.yml ps
```

**Prometheus targets down?** Open `http://YOUR_IP:9090/targets` — `demo-app` should be UP.

## Estimated cost

~$15/month for t3.medium if left running 24/7. Run `.\destroy.ps1` when done.
