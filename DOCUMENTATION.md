# Task6 Stack DevOps - Comprehensive Documentation

## Table of Contents
1. [Project Overview](#project-overview)
2. [Architecture](#architecture)
3. [Technology Stack](#technology-stack)
4. [Project Structure](#project-structure)
5. [Prerequisites](#prerequisites)
6. [Setup & Deployment](#setup--deployment)
7. [GitHub Actions Workflows](#github-actions-workflows)
8. [Configuration Files](#configuration-files)
9. [Usage Guide](#usage-guide)
10. [Troubleshooting](#troubleshooting)

---

## Project Overview

**NATO Phonetic Alphabet Converter - DevOps Stack Project**

This is a learning project demonstrating DevOps engineering practices by deploying a web application (NATO phonetic alphabet converter) on AWS EC2 instances. The project showcases Infrastructure as Code (IaC), configuration management, and CI/CD automation.

**Learning Goals:**
- Infrastructure provisioning with Terraform
- Configuration management with Ansible
- Kubernetes deployment with Minikube
- CI/CD automation with GitHub Actions
- Python Flask web application development

---

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    GitHub Repository                     │
│  ┌─────────────────────────────────────────────────┐    │
│  │         GitHub Actions (CI/CD Workflows)        │    │
│  │  - wf_tf-plan.yml (Terraform Plan)             │    │
│  │  - wf_tf-apply.yml (Terraform Apply)           │    │
│  │  - wf_ansible-config.yml (Ansible Configure)   │    │
│  │  - wf-tf-destroy.yml (Terraform Destroy)       │    │
│  └─────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│                       AWS Account                        │
│  ┌─────────────────────────────────────────────────┐    │
│  │                  AWS Services                    │    │
│  │  ├─ VPC (10.0.0.0/16)                          │    │
│  │  ├─ EC2 Instance (Ubuntu 24.04)                │    │
│  │  ├─ Security Groups (SSH, HTTP)                │    │
│  │  ├─ Internet Gateway                           │    │
│  │  └─ Route Tables & Subnets                     │    │
│  └─────────────────────────────────────────────────┘    │
│                            │                             │
│                            ▼                             │
│  ┌─────────────────────────────────────────────────┐    │
│  │      Ubuntu EC2 Instance with Services          │    │
│  │  ├─ Minikube (Kubernetes)                      │    │
│  │  ├─ Docker Container Runtime                   │    │
│  │  ├─ Python Flask Application                   │    │
│  │  └─ Port Forwarding (80:80)                    │    │
│  └─────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────┘
```

---

## Technology Stack

| Component | Purpose | Version |
|-----------|---------|---------|
| **Terraform** | Infrastructure as Code | ~6.0 (AWS Provider) |
| **Ansible** | Configuration Management | Latest |
| **Kubernetes** | Container Orchestration | Minikube (Latest) |
| **Docker** | Containerization | Latest |
| **Python** | Application Runtime | 3.x |
| **Flask** | Web Framework | Latest |
| **GitHub Actions** | CI/CD Automation | Native |
| **AWS** | Cloud Infrastructure | EC2, VPC, Security Groups |

---

## Project Structure

```
task6_stack_DevOps/
├── README.md                           # Main project README
├── DOCUMENTATION.md                    # This file
├── terraform/                          # Infrastructure as Code
│   ├── main.tf                         # Terraform configuration
│   ├── variables.tf                    # Input variables
│   ├── outputs.tf                      # Output variables
│   ├── backend-dev.hcl                 # Dev environment S3 backend config
│   ├── backend-prod.hcl                # Prod environment S3 backend config
│   ├── envs/
│   │   ├── dev.tfvars                  # Dev environment variables
│   │   └── prod.tfvars                 # Prod environment variables
│   └── README.md                       # Terraform-specific docs
├── ansible/                            # Configuration Management
│   ├── playbook.yml                    # Main Ansible playbook
│   ├── hosts.ini                       # Inventory file
│   ├── k8s/                            # Kubernetes manifests
│   │   ├── nato-deployment.yaml        # Deployment manifest
│   │   ├── nato-service.yaml           # Service manifest
│   │   └── nato-configmap.yaml         # ConfigMap manifest
│   └── README.md                       # Ansible-specific docs
├── .github/
│   └── workflows/                      # GitHub Actions CI/CD
│       ├── wf_tf-plan.yml              # Terraform plan workflow
│       ├── wf_tf-apply.yml             # Terraform apply workflow
│       ├── wf_ansible-config.yml       # Ansible configuration workflow
│       └── wf-tf-destroy.yml           # Terraform destroy workflow
└── app/                                # Flask Application
    ├── app.py                          # Main application
    ├── Dockerfile                      # Container image definition
    └── requirements.txt                # Python dependencies
```

---

## Prerequisites

### Local Development Requirements
- **Git** - Version control
- **Terraform** - v1.13.5 or later
- **Ansible** - 2.9 or later
- **Python** - 3.8 or later
- **AWS CLI** - For AWS credential management
- **Docker** - For local testing (optional)

### AWS Account Requirements
- Active AWS account with EC2, VPC, and S3 permissions
- S3 bucket for Terraform state storage
- IAM user/role with appropriate permissions
- AWS credentials configured locally

### GitHub Configuration
- GitHub repository access (this repository)
- GitHub Actions enabled
- Secrets configured (see Setup & Deployment section)

---

## Setup & Deployment

### 1. Initial Setup

#### Clone the Repository
```bash
git clone https://github.com/zboro93/task6_stack_DevOps.git
cd task6_stack_DevOps
```

#### Configure AWS Credentials
```bash
aws configure
# Enter your AWS Access Key ID, Secret Access Key, and default region
```

### 2. GitHub Secrets Configuration

Set the following secrets in your GitHub repository (Settings > Secrets and Variables > Actions):

```
AWS_ACCESS_KEY_ID          # Your AWS Access Key
AWS_SECRET_ACCESS_KEY      # Your AWS Secret Key
AWS_DEFAULT_REGION         # AWS region (e.g., eu-central-1)
```

### 3. Terraform Backend Setup

Create an S3 bucket for Terraform state:
```bash
aws s3 mb s3://my-terraform-state-bucket
```

Update backend configuration files:
- `terraform/backend-dev.hcl`
- `terraform/backend-prod.hcl`

Example backend-dev.hcl:
```hcl
bucket         = "my-terraform-state-bucket"
key            = "dev/terraform.tfstate"
region         = "eu-central-1"
encrypt        = true
dynamodb_table = "terraform-locks"
```

### 4. Environment Configuration

Update Terraform variable files:
- `terraform/envs/dev.tfvars`
- `terraform/envs/prod.tfvars`

Example variables:
```hcl
aws_region       = "eu-central-1"
env              = "dev"
cidr_block       = "10.0.1.0/24"
availability_zone = "eu-central-1a"
```

### 5. Ansible Hosts Configuration

Update `ansible/hosts.ini`:
```ini
[webservers]
target_instance ansible_host=<EC2_PUBLIC_IP> ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa
```

---

## GitHub Actions Workflows

### 1. Terraform Plan Workflow (`wf_tf-plan.yml`)

**Purpose:** Validates Terraform configuration and creates execution plan

**Trigger:** Manual workflow dispatch (workflow_dispatch)

**Steps:**
1. Checkout repository code
2. Setup Terraform v1.13.5
3. Initialize Terraform backend
4. Format validation (terraform fmt)
5. Configuration validation (terraform validate)
6. Create execution plan (terraform plan)
7. Comment plan results on PR

**Usage:**
```
GitHub Actions > Terraform Plan > Run workflow
- Select environment: dev or prod
```

**Environment Selection:**
- dev: Uses dev.tfvars and backend-dev.hcl
- prod: Uses prod.tfvars and backend-prod.hcl

### 2. Terraform Apply Workflow (`wf_tf-apply.yml`)

**Purpose:** Deploys infrastructure to AWS

**Trigger:** Manual workflow dispatch

**Steps:**
1. Checkout repository code
2. Setup Terraform v1.13.5
3. Initialize Terraform backend
4. Validate configuration
5. Apply Terraform changes
6. Extract EC2 public IP
7. Upload IP to artifacts

**Usage:**
```
GitHub Actions > Terraform Apply > Run workflow
- Select environment: dev or prod
```

**Output Artifacts:**
- `aws-ec2-pub-ip.txt` - Public IP of created EC2 instance

### 3. Ansible Configuration Workflow (`wf_ansible-config.yml`)

**Purpose:** Configures the EC2 instance with applications and services

**Trigger:** Manual workflow dispatch (recommended on PR to main)

**Steps:**
1. Checkout repository code
2. Install Ansible
3. Configure SSH credentials
4. Run playbook against EC2 instance
5. Validate deployment

**Prerequisites:**
- EC2 instance must be running
- Instance must be accessible via SSH
- EC2 public IP must be known

### 4. Terraform Destroy Workflow (`wf-tf-destroy.yml`)

**Purpose:** Tears down AWS infrastructure

**Trigger:** Manual workflow dispatch

**Steps:**
1. Checkout repository code
2. Setup Terraform v1.13.5
3. Initialize backend
4. Destroy infrastructure
5. Approval may be required

**⚠️ WARNING:** This workflow destroys all infrastructure. Use with caution!

---

## Configuration Files

### Terraform Configuration (`terraform/main.tf`)

**AWS Provider:**
- Region: Configurable via variables
- Default tags: Environment, Owner, Task

**VPC Setup:**
- CIDR Block: 10.0.0.0/16
- Public Subnet: Configurable (default: 10.0.1.0/24)
- Internet Gateway: Enables external access
- Route Table: Routes traffic through Internet Gateway

**Security:**
- Security Group: Allows SSH (22) and HTTP (80) inbound
- Egress: Allows HTTP (80) outbound for package downloads
- CIDR: 0.0.0.0/0 (open to internet - consider restricting in production)

**EC2 Instance:**
- AMI: Ubuntu 24.04 LTS (Canonical official image)
- Instance Type: Configurable via variables
- Public IP: Auto-assigned for SSH access

### Ansible Playbook (`ansible/playbook.yml`)

**User Setup:**
- Creates ubuntu user with sudo access
- Configures SSH key-based authentication

**System Updates:**
- Updates package manager
- Installs essential tools (curl, git, etc.)

**Container Runtime:**
- Installs Docker and Docker Compose
- Starts and enables Docker service

**Kubernetes:**
- Installs Minikube
- Installs kubectl
- Installs Python Kubernetes client library
- Deploys Kubernetes manifests from `k8s/` directory

**Application Deployment:**
- Copies Kubernetes manifests to `/tmp/k8s/`
- Creates deployments and services
- Configures port forwarding (80:80)

**Handlers:**
- Debug handlers for verification (expandable for real handlers)

---

## Usage Guide

### Step-by-Step Deployment

#### Phase 1: Create Infrastructure (Terraform)
1. Push code to repository
2. Go to GitHub Actions > Terraform Plan
3. Select environment (dev/prod)
4. Review plan output
5. Go to GitHub Actions > Terraform Apply
6. Select same environment
7. Wait for completion
8. Note the EC2 public IP from artifacts

#### Phase 2: Configure Instance (Ansible)
1. Update `ansible/hosts.ini` with EC2 public IP
2. Ensure SSH key is accessible at `~/.ssh/id_rsa`
3. Go to GitHub Actions > Ansible Configuration
4. Run workflow
5. Monitor for configuration completion

#### Phase 3: Verify Application
1. Access application at `http://<EC2_PUBLIC_IP>`
2. Test NATO alphabet converter functionality
3. Monitor logs: `kubectl logs -f deployment/nato`

### Manual Local Deployment

**Initialize Terraform:**
```bash
cd terraform
terraform init -backend-config="./backend-dev.hcl"
```

**Plan Infrastructure:**
```bash
terraform plan -var-file="envs/dev.tfvars" -out=tfplan
```

**Apply Infrastructure:**
```bash
terraform apply tfplan
terraform output
```

**Get EC2 IP and Update Ansible:**
```bash
EC2_IP=$(terraform output -raw ubuntu_public_ip)
sed -i "s/<EC2_PUBLIC_IP>/$EC2_IP/g" ../ansible/hosts.ini
```

**Configure with Ansible:**
```bash
cd ../ansible
ansible-playbook -i hosts.ini playbook.yml
```

---

## Troubleshooting

### Terraform Issues

**Error: "Missing credentials"**
```bash
Solution: Run 'aws configure' and enter your AWS credentials
```

**Error: "Backend initialization failed"**
```bash
Solution: Verify S3 bucket exists and backend-*.hcl contains correct bucket name
```

**Error: "Security group rules already exist"**
```bash
Solution: Use 'terraform import' or destroy and recreate with 'terraform apply'
```

### Ansible Issues

**Error: "SSH connection refused"**
```bash
Solution: 
1. Verify EC2 instance is running
2. Check security group allows SSH (port 22)
3. Verify SSH key permissions: chmod 600 ~/.ssh/id_rsa
4. Confirm correct IP in hosts.ini
```

**Error: "Failed to set permissions on key file"**
```bash
Solution: Fix SSH key permissions
chmod 600 ~/.ssh/id_rsa
```

**Error: "Minikube start failed"**
```bash
Solution: SSH into EC2 and run: sudo minikube start --driver=docker --force
```

### Application Issues

**Application not accessible via HTTP:**
```bash
Solution:
1. Verify port forwarding is active: ps aux | grep port-forward
2. Check security group allows HTTP (port 80)
3. SSH into instance and verify service: sudo minikube kubectl -- get pods
```

**Kubernetes pods in CrashLoopBackOff:**
```bash
Solution:
1. Check pod logs: kubectl logs <pod-name>
2. Verify container image exists: docker images
3. Check resource limits in deployment manifest
```

### GitHub Actions Issues

**Workflow fails with "Artifact not found"**
```bash
Solution: Previous Terraform Apply workflow must complete successfully before accessing artifacts
```

**Workflow permissions denied**
```bash
Solution: Check GitHub repository settings > Actions > Permissions > Allow all actions
```

---

## Additional Resources

- [Terraform Documentation](https://www.terraform.io/docs)
- [Ansible Documentation](https://docs.ansible.com)
- [Kubernetes Documentation](https://kubernetes.io/docs)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [AWS Documentation](https://docs.aws.amazon.com)

---

## Future Enhancements

- [ ] Add HTTPS/TLS certificate support
- [ ] Implement auto-scaling for Kubernetes pods
- [ ] Add comprehensive logging and monitoring (CloudWatch, Prometheus)
- [ ] Implement secrets management (AWS Secrets Manager)
- [ ] Add database layer (RDS)
- [ ] Implement IaC testing (Terratest, Terraform Validate)
- [ ] Add health checks and automatic recovery
- [ ] Document Kubernetes manifest details

---

## Notes

- All workflows currently use manual triggers (workflow_dispatch)
- Consider implementing branch protection rules for main branch
- SSH access to EC2 is open to 0.0.0.0/0 - restrict in production
- HTTP access is open to 0.0.0.0/0 - consider using ALB with SSL
- Terraform state is stored in S3 - ensure bucket encryption is enabled
- Consider implementing cost optimization measures for production

---

**Project Status:** Learning/Development
**Last Updated:** 2026
**Owner:** zboro93
