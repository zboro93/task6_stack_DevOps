to do: 
02.03 - Kubernetes na ubuntu z imagem

## task6 - Nato phonetic alphabet converter as a DevOps Stack project.
---

**About**

My path to DevOps role.
As preparation and learning to be a DevOps Engineer, I began to perform practical tasks that will help and document my development.  
This task is to build web app - Nato phonetic alphabet converter - hosted on Ubuntu EC2 Instance.

---

## Quick Links

📖 **[Full Documentation](./DOCUMENTATION.md)** - Comprehensive guide with architecture, setup, and troubleshooting  
🚀 **[Quick Start Guide](./QUICK_START.md)** - 30-minute deployment guide  
⚙️ **[Workflow Guide](./WORKFLOW_GUIDE.md)** - Detailed GitHub Actions workflows reference  

---

## Build with

- **Terraform** - Infrastructure as Code (AWS resources)
- **Ansible** - Configuration Management (system setup, Kubernetes deployment)
- **Python** - Application Runtime (Flask backend)
- **Flask** - Web Framework (HTTP server)
- **Docker** - Container Runtime
- **Kubernetes** (Minikube) - Container Orchestration
- **Github Actions** - CI/CD Automation

---

## How it works

### Architecture Overview

```
GitHub Actions CI/CD
    ↓
[Terraform] → Creates AWS Infrastructure (VPC, EC2, Security Groups)
    ↓
[EC2 Instance - Ubuntu 24.04]
    ↓
[Ansible] → Configures system, installs Docker, Kubernetes, Flask app
    ↓
[Minikube + Kubernetes] → Orchestrates NATO converter application
    ↓
[HTTP: 0.0.0.0:80] → NATO Phonetic Alphabet Converter Web App
```

### Deployment Flow

| Step | Tool | Action | Output |
|------|------|--------|--------|
| 1 | **Terraform** | Provisions AWS infrastructure | EC2 instance with public IP |
| 2 | **Ansible** | Configures EC2 instance | Running Kubernetes with NATO app |
| 3 | **Kubernetes** | Deploys application | NATO converter accessible at `http://<IP>` |
| 4 | **Flask App** | Converts text to NATO phonetic | Web interface for user input |

---

## Quick Start

### Prerequisites
- AWS Account with credentials
- GitHub Repository (this one)
- GitHub Actions enabled
- Git installed locally

### 5-Minute Setup

1. **Configure GitHub Secrets**
   - Go to Settings > Secrets and Variables > Actions
   - Add: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_DEFAULT_REGION`

2. **Run Terraform Plan**
   - Actions > Terraform Plan > Run workflow
   - Select environment: `dev`

3. **Run Terraform Apply**
   - Actions > Terraform Apply > Run workflow
   - Copy the EC2 public IP from artifacts

4. **Run Ansible Configuration**
   - Update `ansible/hosts.ini` with EC2 IP
   - Actions > Ansible Configuration > Run workflow

5. **Access Application**
   - Open `http://<EC2_PUBLIC_IP>` in browser

For detailed instructions, see **[QUICK_START.md](./QUICK_START.md)**

---

## Project Structure

```
task6_stack_DevOps/
├── terraform/                    # Infrastructure as Code
│   ├── main.tf                   # AWS resource definitions
│   ├── variables.tf              # Input variables
│   ├── outputs.tf                # EC2 public IP output
│   ├── envs/                     # Environment-specific variables
│   │   ├── dev.tfvars            # Development environment
│   │   └── prod.tfvars           # Production environment
│   └── backend-*.hcl             # S3 backend configuration
│
├── ansible/                      # Configuration Management
│   ├── playbook.yml              # Main playbook (full system setup)
│   ├── hosts.ini                 # Inventory file (EC2 hosts)
│   └── k8s/                      # Kubernetes manifests
│       ├── nato-deployment.yaml  # Kubernetes deployment
│       ├── nato-service.yaml     # Kubernetes service
│       └── nato-configmap.yaml   # Configuration management
│
├── .github/workflows/            # GitHub Actions CI/CD
│   ├── wf_tf-plan.yml            # Plan infrastructure changes
│   ├── wf_tf-apply.yml           # Apply infrastructure changes
│   ├── wf_ansible-config.yml     # Configure EC2 with Ansible
│   └── wf-tf-destroy.yml         # Destroy infrastructure
│
├── app/                          # Flask Application (NATO converter)
│   ├── app.py                    # Flask backend
│   ├── Dockerfile                # Container image
│   └── requirements.txt           # Python dependencies
│
├── DOCUMENTATION.md              # Full documentation
├── QUICK_START.md                # Quick start guide
└── WORKFLOW_GUIDE.md             # Workflow reference
```

---

## GitHub Actions Workflows

### Available Workflows

| Workflow | Trigger | Purpose | Environment |
|----------|---------|---------|-------------|
| **Terraform Plan** | Manual | Validate and preview infrastructure changes | dev/prod |
| **Terraform Apply** | Manual | Deploy infrastructure to AWS | dev/prod |
| **Ansible Config** | Manual | Configure EC2 and deploy application | dev/prod |
| **Terraform Destroy** | Manual | Remove all AWS infrastructure | dev/prod |

**Recommended Execution Order:**
1. Terraform Plan (preview)
2. Terraform Apply (deploy)
3. Ansible Config (configure)
4. Access application

See **[WORKFLOW_GUIDE.md](./WORKFLOW_GUIDE.md)** for detailed workflow documentation.

---

## Key Features

✅ **Infrastructure as Code** - Reproducible AWS infrastructure with Terraform  
✅ **Configuration Management** - Automated system setup with Ansible  
✅ **Container Orchestration** - Kubernetes deployment with Minikube  
✅ **CI/CD Automation** - GitHub Actions workflows for full deployment pipeline  
✅ **Multi-environment** - Support for dev and prod environments  
✅ **Easy Deployment** - One-click deployment via GitHub Actions  
✅ **Complete Documentation** - Comprehensive guides for all components  

---

## Technologies & Versions

- **Terraform**: v1.13.5
- **Ansible**: Latest stable
- **Kubernetes**: Latest (Minikube)
- **Docker**: Latest
- **Python**: 3.x
- **Flask**: Latest
- **Ubuntu**: 24.04 LTS (Canonical)
- **AWS Provider**: ~6.0

---

## Documentation

| Document | Purpose |
|----------|---------|
| **[DOCUMENTATION.md](./DOCUMENTATION.md)** | Full reference with architecture, setup, configuration |
| **[QUICK_START.md](./QUICK_START.md)** | Fast deployment guide (30 minutes) |
| **[WORKFLOW_GUIDE.md](./WORKFLOW_GUIDE.md)** | GitHub Actions workflows reference |
| **[terraform/README.md](./terraform/README.md)** | Terraform-specific documentation |
| **[ansible/README.md](./ansible/README.md)** | Ansible-specific documentation |

---

## Getting Help

**Issues & Troubleshooting:**
- See **[DOCUMENTATION.md - Troubleshooting Section](./DOCUMENTATION.md#troubleshooting)**
- Check GitHub Actions logs for workflow errors
- Review AWS CloudFormation events in AWS console

**Common Issues:**
- AWS credentials not configured → Run `aws configure`
- S3 backend not found → Create S3 bucket and update backend config
- SSH connection refused → Check security group and SSH key permissions
- Ansible playbook fails → Verify EC2 is running and IP is correct

---

## Learning Resources

- **Terraform:** https://www.terraform.io/docs
- **Ansible:** https://docs.ansible.com
- **Kubernetes:** https://kubernetes.io/docs
- **GitHub Actions:** https://docs.github.com/en/actions
- **AWS:** https://docs.aws.amazon.com

---

## Future Enhancements

- [ ] Add HTTPS/TLS support with Let's Encrypt
- [ ] Implement auto-scaling for Kubernetes pods
- [ ] Add monitoring and logging (Prometheus, ELK)
- [ ] Implement secrets management (AWS Secrets Manager)
- [ ] Add database layer (PostgreSQL/RDS)
- [ ] Add backup and disaster recovery
- [ ] Implement GitOps for continuous deployment
- [ ] Add comprehensive testing (unit, integration, e2e)

---

## Notes & Warnings

⚠️ **Security Considerations:**
- SSH access is open to 0.0.0.0/0 - restrict to your IP in production
- HTTP access is open to 0.0.0.0/0 - consider using HTTPS and ALB
- AWS credentials stored in GitHub Secrets - rotate regularly
- Terraform state contains sensitive data - ensure S3 encryption is enabled

💰 **Cost Considerations:**
- EC2 instances incur hourly charges
- Use `Terraform Destroy` workflow to remove resources when not in use
- Monitor AWS billing to avoid unexpected charges
- Enable cost allocation tags for tracking

---

## Project Status

**Status:** Learning/Development  
**Last Updated:** May 21, 2026  
**Owner:** [zboro93](https://github.com/zboro93)  
**Learning Goal:** DevOps Engineering path

---

## Next Steps

1. **Start Here:** Read [QUICK_START.md](./QUICK_START.md)
2. **Understand:** Review [DOCUMENTATION.md](./DOCUMENTATION.md)
3. **Deploy:** Follow workflow steps in [WORKFLOW_GUIDE.md](./WORKFLOW_GUIDE.md)
4. **Learn:** Explore Terraform, Ansible, and Kubernetes configurations
5. **Extend:** Add features and improvements as you learn

---

**Happy Learning! 🚀**
