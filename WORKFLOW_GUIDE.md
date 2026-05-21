# GitHub Actions Workflows - Complete Reference

## Table of Contents
1. [Overview](#overview)
2. [Workflow Triggers](#workflow-triggers)
3. [Terraform Plan Workflow](#terraform-plan-workflow)
4. [Terraform Apply Workflow](#terraform-apply-workflow)
5. [Ansible Configuration Workflow](#ansible-configuration-workflow)
6. [Terraform Destroy Workflow](#terraform-destroy-workflow)
7. [Workflow Execution Guide](#workflow-execution-guide)
8. [Troubleshooting](#troubleshooting)

---

## Overview

This repository uses **GitHub Actions** for Infrastructure as Code (IaC) and Configuration Management automation. All workflows are manually triggered and support multiple environments (dev/prod).

### Workflow Summary

| Workflow | File | Purpose | Status |
|----------|------|---------|--------|
| Terraform Plan | `wf_tf-plan.yml` | Preview infrastructure changes | ✅ Production Ready |
| Terraform Apply | `wf_tf-apply.yml` | Deploy infrastructure to AWS | ✅ Production Ready |
| Ansible Config | `wf_ansible-config.yml` | Configure EC2 and deploy app | ✅ Production Ready |
| Terraform Destroy | `wf-tf-destroy.yml` | Remove all infrastructure | ⚠️ USE WITH CAUTION |

---

## Workflow Triggers

### Current Configuration
- **Trigger Type:** Manual (`workflow_dispatch`)
- **Environment Selection:** dev or prod
- **Authentication:** GitHub Secrets (AWS credentials)

### Commented Triggers (For Reference)
```yaml
# Option 1: Pull Request Trigger
on:
  pull_request:
    branches:
      - main
    paths:
      - terraform/**

# Option 2: Push to Main Branch
on:
  push:
    branches:
      - main
    paths:
      - terraform/**
```

---

## Terraform Plan Workflow

### File Location
`.github/workflows/wf_tf-plan.yml`

### Purpose
Validates Terraform configuration files and generates an execution plan showing what changes will be made to AWS infrastructure.

### How to Run

1. **Navigate to Actions Tab**
   ```
   GitHub Repository → Actions → Terraform Plan
   ```

2. **Click "Run workflow"**
   - Select branch: `main`
   - Select environment: `dev` or `prod`
   - Click "Run workflow"

3. **Monitor Execution**
   - View real-time logs
   - Check for validation errors or warnings

### Workflow Steps Breakdown

```yaml
steps:
  1. Checkout
     └─ Clone repository code
  
  2. Debug Env
     └─ Display selected environment
  
  3. Setup Terraform
     └─ Install Terraform v1.13.5
  
  4. Terraform init
     └─ Initialize backend: backend-${TARGET_ENV}.hcl
  
  5. Terraform format
     └─ Validate HCL formatting: terraform fmt -check
  
  6. Terraform validate
     └─ Check configuration syntax
  
  7. Terraform plan
     └─ Generate execution plan
     └─ Output: tfplan file
  
  8. Save plan output
     └─ Convert plan to readable text
     └─ Save to plan.txt
  
  9. Comment on PR
     └─ Post plan results as PR comment (if PR)
```

### Expected Output

**Success Output:**
```
Plan: X to add, Y to change, Z to destroy.
```

**Common Validation Checks:**
- ✅ HCL Formatting valid
- ✅ All variables defined
- ✅ Resource references correct
- ✅ Syntax errors detected and reported

### Environment Variables
```yaml
AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
AWS_DEFAULT_REGION: ${{ secrets.AWS_DEFAULT_REGION }}
TARGET_ENV: ${{ github.event.inputs.environment }}
```

### Troubleshooting

**Error: "Failed to acquire state lock"**
```
Issue: Another workflow is accessing the state
Solution: Wait for previous workflow to complete
```

**Error: "Missing required variable"**
```
Issue: Variable not in tfvars file
Solution: Update terraform/envs/${ENV}.tfvars with required variables
```

**Error: "Invalid backend configuration"**
```
Issue: backend-${ENV}.hcl not found or misconfigured
Solution: Verify backend file exists and S3 bucket name is correct
```

---

## Terraform Apply Workflow

### File Location
`.github/workflows/wf_tf-apply.yml`

### Purpose
Applies the Terraform plan to AWS, creating and modifying infrastructure resources. Extracts and outputs the EC2 instance public IP.

### How to Run

1. **Run Terraform Plan First**
   - Ensure `wf_tf-plan.yml` completes successfully
   - Review plan output for expected changes

2. **Navigate to Actions Tab**
   ```
   GitHub Repository → Actions → Terraform Apply
   ```

3. **Click "Run workflow"**
   - Select branch: `main`
   - Select environment: `dev` or `prod` (MUST match Plan)
   - Click "Run workflow"

4. **Wait for Completion**
   - Workflow typically takes 2-5 minutes
   - Monitor logs for any errors

5. **Retrieve EC2 Public IP**
   - Download artifact: `aws-ec2-pub-ip.txt`
   - Contains public IP for SSH and HTTP access

### Workflow Steps Breakdown

```yaml
steps:
  1. Checkout
     └─ Clone repository code
  
  2. Debug Env
     └─ Display selected environment
  
  3. Setup Terraform
     └─ Install Terraform v1.13.5
  
  4. Terraform init
     └─ Initialize backend
  
  5. Terraform validate
     └─ Verify configuration
  
  6. Terraform apply
     └─ Create AWS resources
     └─ Flag: -auto-approve (no confirmation needed)
  
  7. Terraform output
     └─ Display all outputs
     └─ Includes: EC2 public IP, VPC ID, etc.
  
  8. Save Public IP
     └─ Extract public IP to file
  
  9. Upload Artifact
     └─ Save aws-ec2-pub-ip.txt
     └─ Download from Actions > Artifacts
```

### Expected Output

**Console Output:**
```
aws_instance.example: Creating...
aws_instance.example: Creation complete after 30s
```

**Artifacts:**
```
Artifact: aws-ec2-pub-ip
├─ aws-ec2-pub-ip.txt
└─ Contains: 203.0.113.45 (example IP)
```

### Key Variables
```hcl
aws_region       = "eu-central-1"  # AWS region
env              = "dev"           # Environment name
cidr_block       = "10.0.1.0/24"   # Subnet CIDR
availability_zone = "eu-central-1a" # AZ for subnet
instance_type    = "t3.micro"      # EC2 instance type
```

### Resource Creation

**VPC Resources:**
- VPC with CIDR 10.0.0.0/16
- Public Subnet
- Internet Gateway
- Route Table and Association
- Security Group (SSH + HTTP)

**EC2 Instance:**
- AMI: Ubuntu 24.04 LTS (Canonical)
- Public IP: Auto-assigned
- Security Group: Allows SSH (22) and HTTP (80)
- Key Pair: Optional (configure in variables)

### Troubleshooting

**Error: "Insufficient capacity"**
```
Issue: AWS can't provision in selected AZ
Solution: Try different availability zone or instance type
```

**Error: "VPC CIDR conflict"**
```
Issue: CIDR block already exists
Solution: Use different CIDR range or region
```

**Error: "Access Denied"**
```
Issue: AWS credentials missing EC2 permissions
Solution: Verify IAM user/role has EC2, VPC, and tag permissions
```

---

## Ansible Configuration Workflow

### File Location
`.github/workflows/wf_ansible-config.yml`

### Purpose
Configures the EC2 instance by:
- Installing Docker and container runtime
- Setting up Kubernetes (Minikube)
- Deploying the NATO converter application
- Configuring port forwarding

### Prerequisites

1. **EC2 Instance Running**
   - Must have completed Terraform Apply
   - Instance must be accessible via SSH

2. **EC2 Public IP**
   - Obtain from Terraform Apply artifacts
   - Will use this in next step

3. **SSH Key Configured**
   - GitHub must have SSH private key in secrets (optional)
   - OR configure locally: `ssh-keygen -t rsa`

### How to Run

1. **Get EC2 Public IP**
   - Download `aws-ec2-pub-ip.txt` from Terraform Apply artifacts
   - Example: `203.0.113.45`

2. **Update Ansible Inventory**
   ```
   Edit: ansible/hosts.ini
   
   [webservers]
   target_instance ansible_host=203.0.113.45 ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa
   ```

3. **Navigate to Actions Tab**
   ```
   GitHub Repository → Actions → Ansible Configuration
   ```

4. **Click "Run workflow"**
   - Select branch: `main`
   - Click "Run workflow"

5. **Monitor Execution**
   - Workflow takes 5-15 minutes depending on server speed
   - Watch logs for Docker, Minikube, and Kubernetes deployment

### Workflow Steps (From wf_ansible-config.yml)

```yaml
steps:
  1. Checkout
     └─ Clone repository including ansible/
  
  2. Run Ansible Playbook
     └─ Execute: ansible-playbook -i hosts.ini playbook.yml
     └─ Installs: Docker, Minikube, Python, Kubernetes tools
     └─ Deploys: NATO converter app
     └─ Configures: Port forwarding (80:80)
```

### Playbook Tasks (ansible/playbook.yml)

```yaml
Pre-flight:
  - Update package manager (apt update/upgrade)
  - Install build tools

System Setup:
  - Create ubuntu user (if needed)
  - Configure SSH access

Container Runtime:
  - Install Docker CE
  - Install Docker Compose
  - Add Docker repository
  - Start Docker service

Kubernetes Setup:
  - Install Minikube
  - Install kubectl
  - Install Kubernetes Python client
  - Install PyYAML

Application Deployment:
  - Copy Kubernetes manifests to /tmp/k8s/
  - Start Minikube with Docker driver
  - Apply Kubernetes manifests
  - Wait for pods to be ready

Port Forwarding:
  - Forward container port 80 to host port 80
  - Enable 0.0.0.0 binding for external access
  - Log output to /tmp/port-forward.log
```

### Kubernetes Manifests Deployed

**NATO Deployment:**
- Container image: `zboromir/nato:latest`
- Replicas: 1 (configurable)
- Port: 80 (HTTP)
- Labels: `app=nato`

**NATO Service:**
- Type: ClusterIP or NodePort
- Port: 80
- Selector: `app=nato`

**ConfigMap:**
- Application configuration
- Environment variables

### Expected Output

**Successful Deployment:**
```
PLAY RECAP
target_instance : ok=XX changed=YY unreachable=0 failed=0
```

**Verification Steps:**
1. SSH into EC2: `ssh -i ~/.ssh/id_rsa ubuntu@<IP>`
2. Check Minikube: `minikube status`
3. Check pods: `minikube kubectl -- get pods`
4. Test HTTP: `curl http://localhost`

### Troubleshooting

**Error: "Connection refused"**
```
Issue: SSH port not accessible
Solution: 
1. Check security group allows SSH (22)
2. Verify EC2 is running
3. Confirm correct IP address
```

**Error: "Failed to start Minikube"**
```
Issue: Docker not running or insufficient resources
Solution:
1. SSH to EC2 and check: docker ps
2. Restart Docker: sudo systemctl restart docker
3. Check available memory: free -h
```

**Error: "Pod in CrashLoopBackOff"**
```
Issue: Application failed to start
Solution:
1. Check pod logs: kubectl logs <pod-name>
2. Verify container image exists
3. Check resource requests vs available resources
```

**Port Forwarding Not Working**
```
Issue: Port forward process died
Solution:
1. Check process: ps aux | grep port-forward
2. Restart manually: sudo minikube kubectl -- port-forward service/nato-service 80:80
```

---

## Terraform Destroy Workflow

### File Location
`.github/workflows/wf-tf-destroy.yml`

### Purpose
Removes all AWS infrastructure created by Terraform Apply. Use this to clean up resources and avoid unnecessary costs.

### ⚠️ WARNING
**This workflow is destructive!**
- Deletes EC2 instances
- Destroys VPC and networking
- Removes security groups
- Deletes all data (non-recoverable)

### How to Run

1. **Navigate to Actions Tab**
   ```
   GitHub Repository → Actions → Terraform Destroy
   ```

2. **Click "Run workflow"**
   - Select branch: `main`
   - Select environment: `dev` or `prod` (MUST match previous Apply)
   - Click "Run workflow"

3. **Confirm Destruction**
   - Terraform will ask for confirmation
   - Type `yes` to proceed (or check logs for approval mechanism)

4. **Wait for Completion**
   - Workflow typically takes 2-5 minutes
   - Verify in AWS console that resources are deleted

### Workflow Steps

```yaml
steps:
  1. Checkout
  2. Setup Terraform
  3. Terraform init
  4. Terraform destroy
     └─ Removes all resources
     └─ May require confirmation
```

### Resources Destroyed

**Compute:**
- EC2 instance
- Elastic IPs

**Networking:**
- VPC
- Subnets
- Internet Gateway
- Route Tables
- Security Groups

**Storage:**
- EBS volumes (if created)

### Troubleshooting

**Error: "Resource still in use"**
```
Issue: AWS can't delete resource (has dependencies)
Solution: Manually delete in AWS console or run destroy again
```

**Error: "Access Denied"**
```
Issue: Credentials don't have destroy permissions
Solution: Verify IAM user has EC2 delete permissions
```

---

## Workflow Execution Guide

### Recommended Execution Flow

```
START
  ↓
[1] Terraform Plan
    └─ Review infrastructure changes
    └─ Check for errors
  ↓
[2] Terraform Apply
    └─ Create AWS resources
    └─ Save EC2 public IP
  ↓
[3] Wait 1 minute
    └─ Let EC2 start up completely
  ↓
[4] Update ansible/hosts.ini
    └─ Insert EC2 public IP
  ↓
[5] Ansible Configuration
    └─ Configure EC2 with Docker/Kubernetes
    └─ Deploy NATO app
  ↓
[6] Wait 2 minutes
    └─ Let application fully start
  ↓
[7] Access Application
    └─ Open: http://<EC2_PUBLIC_IP>
    └─ Test NATO converter
  ↓
[8] Cleanup (When Done)
    └─ Run: Terraform Destroy
    └─ Stops incurring AWS costs
  ↓
END
```

### Parallel Execution Restrictions

**Do NOT run workflows in parallel:**
- Terraform workflows access shared state file
- Running Plan + Apply simultaneously causes lock conflict
- Ansible needs Apply to complete first

**Safe Sequence:**
1. ✅ Plan → wait for completion
2. ✅ Apply → wait for completion
3. ✅ Ansible → can run after Apply

---

## GitHub Secrets Configuration

### Required Secrets

Create these secrets in: **Settings > Secrets and Variables > Actions**

```
AWS_ACCESS_KEY_ID
├─ Type: Text
├─ Value: Your AWS Access Key
└─ Required: Yes

AWS_SECRET_ACCESS_KEY
├─ Type: Secret
├─ Value: Your AWS Secret Key
└─ Required: Yes

AWS_DEFAULT_REGION
├─ Type: Text
├─ Value: AWS region (e.g., eu-central-1)
└─ Required: Yes
```

### How to Create Secrets

1. Go to **Repository Settings**
2. Click **Secrets and Variables** → **Actions**
3. Click **New repository secret**
4. Enter name (e.g., `AWS_ACCESS_KEY_ID`)
5. Paste value
6. Click **Add secret**
7. Repeat for each secret

### Security Best Practices

- ✅ Use IAM user (not root account)
- ✅ Grant minimum required permissions
- ✅ Rotate keys regularly
- ✅ Never commit credentials to repository
- ✅ Monitor AWS CloudTrail for API usage
- ✅ Enable MFA for AWS account

---

## Troubleshooting

### General Workflow Issues

**Workflow appears to be stuck**
```
Solution:
1. Check GitHub Actions rate limiting (workflow quota)
2. Check AWS API limits (can be hit during resource creation)
3. Kill workflow and retry
```

**"Artifact not found" when downloading**
```
Solution:
1. Ensure previous workflow completed successfully
2. Artifacts expire after 90 days by default
3. Re-run workflow to regenerate artifact
```

**Permission denied errors**
```
Solution:
1. Verify AWS IAM permissions
2. Check GitHub repository permissions
3. Ensure branch protection rules aren't blocking
```

### Workflow-Specific Issues

See individual workflow sections above for:
- Terraform Plan troubleshooting
- Terraform Apply troubleshooting
- Ansible Configuration troubleshooting
- Terraform Destroy troubleshooting

---

## Monitoring & Logging

### Access Workflow Logs

1. **During Execution**
   - Click running workflow
   - View live logs

2. **After Completion**
   - Click completed workflow
   - View full execution logs
   - Download logs as artifact

### Important Log Sections

**Terraform Plan:**
- Look for: "Plan: X to add, Y to change, Z to destroy"
- Errors: Red text with error messages
- Warnings: Yellow text with recommendations

**Terraform Apply:**
- Look for: "Apply complete! Resources: X added"
- Output section: Shows all outputs (like EC2 IP)
- Errors: Red text showing what failed

**Ansible Playbook:**
- Look for: "PLAY RECAP" at end
- Status: "ok", "changed", "failed"
- Task output: Detailed per-task execution

---

## Environment Configuration

### Dev Environment Setup

**terraform/envs/dev.tfvars:**
```hcl
aws_region         = "eu-central-1"
env                = "dev"
cidr_block         = "10.0.1.0/24"
availability_zone  = "eu-central-1a"
instance_type      = "t3.micro"  # Cost-effective
```

### Production Environment Setup

**terraform/envs/prod.tfvars:**
```hcl
aws_region         = "eu-central-1"
env                = "prod"
cidr_block         = "10.0.1.0/24"
availability_zone  = "eu-central-1a"
instance_type      = "t3.small"  # More resources
```

---

## Best Practices

1. **Always run Plan first** - Review changes before Apply
2. **Separate dev/prod** - Use different environments
3. **Use version control** - Commit all changes to git
4. **Document changes** - Add commit messages explaining why
5. **Monitor costs** - Check AWS billing regularly
6. **Backup state** - S3 state file is backed up automatically
7. **Test changes** - Deploy to dev before prod
8. **Destroy when done** - Remove resources to save costs

---

## Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Terraform Workflows](https://www.terraform.io/cloud-docs/workspaces)
- [Ansible Documentation](https://docs.ansible.com/ansible/)
- [AWS CLI Reference](https://docs.aws.amazon.com/cli/)

---

**Last Updated:** 2026  
**Status:** Production Ready  
**Questions?** Refer to [DOCUMENTATION.md](./DOCUMENTATION.md) for comprehensive guide
