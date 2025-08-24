# SSH Authetication Failure Metrics Alert
## Setup

### 1. Provision EC2 Instance

Use Terraform ([main.tf](main.tf)) to launch an Ubuntu EC2 instance with required security groups and SSH key.

terraform init
terraform apply

### 2. Configure EC2
The instance runs userdata_1.sh on boot to:

Install SSM Agent
Install Docker & Nginx
Deploy a sample Docker Compose app
### 3. Install CloudWatch Agent
See cw-agent-download-link.md for installation steps.

Configure the agent using amazon-cloudwatch-agent.json to collect /var/log/auth.log and send to CloudWatch.

### 4. IAM Policy
Attach the policy in iam-policies/cloudwatch-agent-ec2-policy.json to your EC2 instance role for CloudWatch access.

### 5. CloudWatch Log Group & Metric Filter
Deploy the CloudFormation template ec2-ssh-logs.yaml to create:

Log group: ec2-ssh-logs
Metric filter: Counts failed SSH logins
Monitoring & Alerts
View SSH failure metrics in CloudWatch under namespace SSH, metric name FailedSSHLoginCount.
Set up CloudWatch Alarms for notifications on suspicious activity.
