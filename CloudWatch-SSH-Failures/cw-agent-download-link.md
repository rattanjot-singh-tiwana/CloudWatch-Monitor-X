wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb

sudo dpkg -i amazon-cloudwatch-agent.deb

# You can verify if it is installed by running the command:

amazon-cloudwatch-agent-ctl

# To check its status, run:

amazon-cloudwatch-agent-ctl -a status