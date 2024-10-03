#!/usr/bin/env bash
set -euo pipefail
case $(uname -m) in
x86_64) ARCH=amd64 ;;
aarch64) ARCH=arm64 ;;
*) ARCH=unknown ;;
esac

echo "Installing cloudwatch agent..."
echo "installing aws-cfn-bootstrap..."
wget https://amazoncloudwatch-agent.s3.amazonaws.com/debian/${ARCH}/latest/amazon-cloudwatch-agent.deb
sudo dpkg -i -E ./amazon-cloudwatch-agent.deb

echo "Adding amazon-cloudwatch-agent config..."
sudo cp /tmp/conf/cloudwatch-agent/config.json /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

echo "Configuring amazon-cloudwatch-agent to start at boot"
sudo systemctl enable amazon-cloudwatch-agent

# These will send some systemctl service logs (like the buildkite agent and docker) to logfiles
echo "Adding rsyslogd configs..."
sudo cp /tmp/conf/cloudwatch-agent/rsyslog.d/* /etc/rsyslog.d/
