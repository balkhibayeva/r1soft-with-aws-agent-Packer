 #!/bin/bash
sudo yum update -y
sudo cp  /tmp/r1soft.repo  /etc/yum.repos.d/
sudo mv /etc/yum.repos.d/Cen* /tmp/
sudo yum install r1soft-cdp-enterprise-server -y
sudo r1soft-setup --user aizada --pass cholpon  --http-port 8080
sudo /etc/init.d/cdp-server restart
sudo curl -O https://inspector-agent.amazonaws.com/linux/latest/install
sudo bash install https://docs.aws.amazon.com/inspector/latest/userguide/inspector_installing-uninstalling-agents.html