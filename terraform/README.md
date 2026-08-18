# Terraform — Milestone 2: VPC + Jenkins EC2

Terraform CLI wasn't available in the sandbox that generated this, so these
files haven't been run/validated yet — you'll be the first to `terraform
init` them. Read through each `.tf` file before applying so you understand
every resource; that understanding is what interviewers actually test.

## Prerequisites
- Terraform CLI installed (`terraform -version`)
- AWS CLI installed and configured (`aws configure`) with your IAM user's
  access key + secret key
- An EC2 key pair already created in the AWS Console (EC2 → Key Pairs) in
  the region you're using — you'll reference it by name, Terraform doesn't
  create it for you
- Your current public IP: `curl https://checkip.amazonaws.com`

## Step 1 — Bootstrap the remote state backend (run ONCE, ever)
```bash
cd bootstrap
# Edit variables.tf: set state_bucket_name to something globally unique
terraform init
terraform apply
# Note the two outputs: state_bucket_name and lock_table_name
```
This uses **local** state (there's no S3 bucket yet to store state in —
that's what this step creates). Don't run `terraform destroy` here later
unless you're tearing down the whole project permanently; it holds the
state for everything else.

## Step 2 — Wire the bucket into the main config
Open `vpc-jenkins/backend.tf` and replace `clouddeploy-tfstate-CHANGE-ME`
and `clouddeploy-tf-locks` with the exact values from Step 1's outputs.

## Step 3 — Provision the VPC + Jenkins EC2
```bash
cd ../vpc-jenkins
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars: set my_ip and key_name to your own values
terraform init
terraform plan   # read this output before applying — know what it's creating
terraform apply
```
Apply takes 1-2 minutes for AWS resources; Jenkins itself takes another
1-2 minutes to finish installing via `user_data.sh` after the instance
boots.

## Step 4 — Get into Jenkins
```bash
terraform output jenkins_url
```
Open that URL in your browser. To get the initial admin password:
```bash
ssh -i /path/to/your-key.pem ec2-user@$(terraform output -raw jenkins_public_ip)
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```
Paste that into the Jenkins setup wizard, install the suggested plugins,
create your admin user.

## Cost control — do this after every work session
```bash
terraform destroy
```
This tears down the EC2 instance (the only thing costing money here — the
VPC itself is free). Re-running `terraform apply` next session brings back
an identical, working Jenkins box in ~3 minutes. This destroy/recreate
habit is worth mentioning explicitly in interviews — it shows cost
awareness.

## Milestone 2 exit criteria
- [ ] `terraform apply` from a clean state brings up a working, SSH-able
      Jenkins server
- [ ] You can log into the Jenkins UI at `http://<public-ip>:8080`
- [ ] `terraform destroy` then `terraform apply` again produces an
      identical, working box — proving nothing was set up by hand
