# Quick Start Guide - 30-Minute Deployment

Deploy the NATO Phonetic Alphabet Converter on AWS in 30 minutes!

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Step 1: AWS Account Setup (5 min)](#step-1-aws-account-setup-5-min)
3. [Step 2: GitHub Secrets Configuration (3 min)](#step-2-github-secrets-configuration-3-min)
4. [Step 3: Terraform Backend Setup (5 min)](#step-3-terraform-backend-setup-5-min)
5. [Step 4: Deploy Infrastructure (5 min)](#step-4-deploy-infrastructure-5-min)
6. [Step 5: Configure Application (10 min)](#step-5-configure-application-10-min)
7. [Step 6: Access Your Application (2 min)](#step-6-access-your-application-2-min)
8. [Cleanup](#cleanup)

---

## Prerequisites

### Required
- ✅ AWS account (free tier eligible)
- ✅ GitHub account and this repository
- ✅ 30 minutes of time
- ✅ Internet connection

### Software (Local Machine)
- Git
- AWS CLI (optional but recommended)

### No Installation Needed!
- Terraform (runs in GitHub Actions)
- Ansible (runs in GitHub Actions)
- Docker (runs in EC2)
- Kubernetes (runs in EC2)

---

## Step 1: AWS Account Setup (5 min)

### 1.1 Create IAM User

1. Go to [AWS IAM Console](https://console.aws.amazon.com/iam)
2. Click **Users** in left sidebar
3. Click **Create user**
   - Username: `devops-user`
   - Click **Next**
4. Click **Attach policy directly**
5. Search and select:
   - ✅ `EC2FullAccess`
   - ✅ `VPCFullAccess`
   - ✅ `S3FullAccess`
   - ✅ `SecurityGroupFullAccess`
   - Click **Next**
6. Click **Create user**

### 1.2 Create Access Keys

1. Click the user `devops-user`
2. Click **Security credentials** tab
3. Scroll to **Access keys**
4. Click **Create access key**
5. Select **Command Line Interface (CLI)**
6. Accept acknowledgment
7. Click **Create access key**
8. **IMPORTANT:** Copy both:
   - Access Key ID
   - Secret Access Key
   - (You won't see this again!)

**Save these securely - you'll need them in Step 2!**

---

## Step 2: GitHub Secrets Configuration (3 min)

### 2.1 Add AWS Credentials to GitHub

1. Go to your GitHub repository
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**

**Add Secret #1: AWS_ACCESS_KEY_ID**
- Name: `AWS_ACCESS_KEY_ID`
- Secret: *paste your Access Key ID*
- Click **Add secret**

**Add Secret #2: AWS_SECRET_ACCESS_KEY**
- Name: `AWS_SECRET_ACCESS_KEY`
- Secret: *paste your Secret Access Key*
- Click **Add secret**

**Add Secret #3: AWS_DEFAULT_REGION**
- Name: `AWS_DEFAULT_REGION`
- Secret: `eu-central-1` (or your preferred region)
- Click **Add secret**

✅ All secrets added!

---

## Step 3: Terraform Backend Setup (5 min)

### 3.1 Create S3 Bucket

1. Go to [AWS S3 Console](https://s3.console.aws.amazon.com)
2. Click **Create bucket**
3. **Bucket name:** `my-terraform-state-bucket-12345`
   - ⚠️ Must be globally unique (add random numbers)
4. **Region:** Same as `AWS_DEFAULT_REGION` (eu-central-1)
5. Scroll down → Check **Block all public access** (keep enabled)
6. Click **Create bucket**

### 3.2 Update Backend Configuration

1. Clone this repository (if not already cloned):
   ```bash
   git clone https://github.com/zboro93/task6_stack_DevOps.git
   cd task6_stack_DevOps
   ```

2. Edit `terraform/backend-dev.hcl`:
   ```hcl
   bucket         = "my-terraform-state-bucket-12345"  # Your bucket name
   key            = "dev/terraform.tfstate"
   region         = "eu-central-1"
   encrypt        = true
   dynamodb_table = "terraform-locks"
   ```

3. Edit `terraform/backend-prod.hcl`:
   ```hcl
   bucket         = "my-terraform-state-bucket-12345"  # Same bucket
   key            = "prod/terraform.tfstate"
   region         = "eu-central-1"
   encrypt        = true
   dynamodb_table = "terraform-locks"
   ```

4. Commit and push:
   ```bash
   git add terraform/backend-*.hcl
   git commit -m "Update S3 backend configuration"
   git push origin main
   ```

✅ Backend configured!

---

## Step 4: Deploy Infrastructure (5 min)

### 4.1 Run Terraform Plan

1. Go to your repository on GitHub
2. Click **Actions** tab
3. Click **Terraform Plan** workflow
4. Click **Run workflow** button
5. Select environment: **dev**
6. Click **Run workflow**
7. Wait for completion (~1-2 minutes)
8. ✅ Check output: "Plan: X to add, Y to change, Z to destroy"

### 4.2 Run Terraform Apply

1. Go back to **Actions** tab
2. Click **Terraform Apply** workflow
3. Click **Run workflow** button
4. Select environment: **dev** (same as Plan!)
5. Click **Run workflow**
6. Wait for completion (~2-3 minutes)

### 4.3 Get EC2 Public IP

1. Wait for **Terraform Apply** to complete
2. Look for **Artifacts** in the workflow summary
3. Download `aws-ec2-pub-ip` artifact
4. Extract and open `aws-ec2-pub-ip.txt`
5. **Copy the IP address** (e.g., `203.0.113.45`)

✅ Infrastructure deployed!

---

## Step 5: Configure Application (10 min)

### 5.1 Update Ansible Inventory

1. Edit `ansible/hosts.ini`:
   ```ini
   [webservers]
   target_instance ansible_host=203.0.113.45 ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa
   ```
   Replace `203.0.113.45` with your EC2 public IP

2. Commit and push:
   ```bash
   git add ansible/hosts.ini
   git commit -m "Update EC2 IP in Ansible inventory"
   git push origin main
   ```

### 5.2 Run Ansible Configuration

1. Go to **Actions** tab
2. Click **Ansible Configuration** workflow
3. Click **Run workflow** button
4. Click **Run workflow**
5. Wait for completion (~5-10 minutes)

**This workflow will:**
- Install Docker
- Install Kubernetes (Minikube)
- Deploy NATO converter app
- Configure port forwarding
- Make app accessible on port 80

### 5.3 Verify Deployment

The workflow logs should show:
```
PLAY RECAP
target_instance : ok=XX changed=YY unreachable=0 failed=0
```

✅ Application deployed!

---

## Step 6: Access Your Application (2 min)

### 6.1 Open Application

1. Open browser
2. Go to: `http://203.0.113.45` (use your EC2 IP)
3. 🎉 See NATO Phonetic Alphabet Converter!

### 6.2 Test It Out

1. Enter text (e.g., "HELLO")
2. Click convert
3. See NATO phonetic alphabet output (e.g., "Hotel Echo Lima Lima Oscar")

### 6.3 Verify Infrastructure

SSH into your instance (optional):
```bash
ssh -i ~/.ssh/id_rsa ubuntu@203.0.113.45

# Inside the instance:
sudo minikube kubectl -- get pods
sudo minikube kubectl -- get services
docker ps
```

✅ Everything working! 🚀

---

## Troubleshooting

### Common Issues

**1. "Resource already exists"**
```
Cause: You've deployed before with same names
Fix: Use terraform destroy first, or change environment names
```

**2. "SSH connection refused"**
```
Cause: Security group or IP address issue
Fix:
1. Verify EC2 is running in AWS console
2. Check security group allows SSH (port 22)
3. Use correct EC2 public IP
4. Wait 2 minutes for EC2 to fully start
```

**3. "Ansible playbook failed"**
```
Cause: Usually SSH key permissions or wrong IP
Fix:
1. Check SSH key permissions: chmod 600 ~/.ssh/id_rsa
2. Verify IP in ansible/hosts.ini is correct
3. Try SSH manually: ssh -i ~/.ssh/id_rsa ubuntu@<IP>
```

**4. "Application not accessible via HTTP"**
```
Cause: Port forwarding not active
Fix:
1. SSH into EC2
2. Check: ps aux | grep port-forward
3. If not running: sudo minikube kubectl -- port-forward service/nato-service 80:80 --address 0.0.0.0
4. Try accessing again
```

**5. "Workflow fails with permission error"**
```
Cause: IAM user doesn't have permissions
Fix:
1. Add missing permissions to IAM user
2. Verify AWS credentials are correct
3. Check GitHub secrets are set correctly
```

### Getting More Help

- See **[WORKFLOW_GUIDE.md](./WORKFLOW_GUIDE.md)** for detailed workflow troubleshooting
- See **[DOCUMENTATION.md](./DOCUMENTATION.md)** for comprehensive troubleshooting
- Check GitHub Actions logs for specific error messages

---

## Cost Estimation

### AWS Charges (First Month)

| Resource | Pricing | Cost |
|----------|---------|------|
| EC2 t3.micro (1 month) | $0.0104/hour × 730 hours | ~$7.59 |
| VPC/Data Transfer | ~$0.50 | $0.50 |
| **Total** | | **~$8.09** |

**Free Tier Eligible!** First 12 months include:
- 750 free EC2 hours
- 1 GB free VPC data

### Cost Optimization

- ✅ Use free tier when possible
- ✅ Destroy resources when not using (saves ~$0.26/day)
- ✅ Use dev environment for testing
- ✅ Monitor AWS billing dashboard

---

## Cleanup & Cost Savings

### Option 1: Stop Instance (Cheap)
Keeps instance but stops charges:
```bash
aws ec2 stop-instances --instance-ids i-xxxxx --region eu-central-1
```

### Option 2: Destroy All (Free)
Removes all resources:

1. Go to **Actions** tab
2. Click **Terraform Destroy** workflow
3. Click **Run workflow**
4. Select environment: **dev**
5. Click **Run workflow**
6. Wait for completion

**⚠️ WARNING:** This is permanent! All data will be deleted.

---

## Next Steps

### Learn More

1. **Understand the Architecture**
   - Read: [DOCUMENTATION.md](./DOCUMENTATION.md)
   - Explore Terraform files: `terraform/main.tf`
   - Explore Ansible playbook: `ansible/playbook.yml`

2. **Customize the Application**
   - Modify Flask app: `app/app.py`
   - Create new Docker image: `docker build -t myapp .`
   - Update Kubernetes manifest: `ansible/k8s/nato-deployment.yaml`

3. **Add More Features**
   - Add database (PostgreSQL/RDS)
   - Add SSL/HTTPS with Let's Encrypt
   - Add monitoring and logging
   - Add auto-scaling

4. **Deploy to Production**
   - Use prod environment: `prod.tfvars`
   - Add security hardening
   - Configure backups
   - Set up high availability

### DevOps Learning Path

1. ✅ Infrastructure as Code (Terraform) - Done!
2. ✅ Configuration Management (Ansible) - Done!
3. ✅ Container Orchestration (Kubernetes) - Done!
4. ✅ CI/CD Automation (GitHub Actions) - Done!
5. 📚 Next: Monitoring, Logging, Security, Scaling

---

## Quick Reference

### Useful Commands

```bash
# Access EC2 instance
ssh -i ~/.ssh/id_rsa ubuntu@<EC2_IP>

# View logs inside EC2
sudo minikube kubectl -- logs -f deployment/nato

# Get Kubernetes status
sudo minikube kubectl -- get pods
sudo minikube kubectl -- get services

# Test HTTP endpoint
curl http://<EC2_IP>
curl http://<EC2_IP>/convert?text=HELLO

# View Terraform state
aws s3 ls s3://my-terraform-state-bucket-12345/

# View AWS resources
aws ec2 describe-instances --region eu-central-1
```

### Important Endpoints

```
Web Application:  http://<EC2_IP>
Kubernetes API:   Inside EC2 via minikube
SSH Access:       ssh ubuntu@<EC2_IP> -i ~/.ssh/id_rsa
S3 Bucket:        s3://my-terraform-state-bucket-12345/
```

### Important Files

```
terraform/envs/dev.tfvars        → Dev environment variables
terraform/backend-dev.hcl         → Dev S3 backend config
ansible/hosts.ini                 → Ansible inventory (EC2 hosts)
ansible/playbook.yml              → Ansible configuration
.github/workflows/                → GitHub Actions workflows
```

---

## Success Checklist

- [ ] AWS account created with IAM user
- [ ] GitHub secrets configured (3 secrets)
- [ ] S3 bucket created for Terraform state
- [ ] Backend configuration updated
- [ ] Terraform Plan completed successfully
- [ ] Terraform Apply completed successfully
- [ ] EC2 public IP obtained
- [ ] Ansible inventory updated
- [ ] Ansible Configuration completed successfully
- [ ] Application accessible at http://<EC2_IP>
- [ ] NATO converter working (tested)
- [ ] Cleanup: Resources destroyed (if cost-saving)

---

## Summary

### What You Did
✅ Created AWS infrastructure (VPC, EC2, Security Groups)  
✅ Configured EC2 instance with Docker & Kubernetes  
✅ Deployed NATO Phonetic Converter application  
✅ Set up complete CI/CD pipeline  

### What You Learned
📚 Infrastructure as Code (Terraform)  
📚 Configuration Management (Ansible)  
📚 Container Orchestration (Kubernetes)  
📚 CI/CD Automation (GitHub Actions)  

### What's Next
🚀 Customize the application  
🚀 Explore production deployment  
🚀 Add monitoring and logging  
🚀 Continue your DevOps journey!

---

**Congratulations! You've successfully deployed a full DevOps stack! 🎉**

For more information, see:
- [Full Documentation](./DOCUMENTATION.md)
- [Workflow Guide](./WORKFLOW_GUIDE.md)
- [Main README](./README.md)

**Happy learning! 📚**
