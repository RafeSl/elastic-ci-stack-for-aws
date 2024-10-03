#!/usr/bin/env bash

set -euo pipefail

case $(uname -m) in
x86_64) ARCH=amd64 ;;
aarch64) ARCH=arm64 ;;
*) ARCH=unknown ;;
esac

echo Updating core packages
sudo apt-get update

echo Installing utils...
sudo apt-get install -yq \
  apt-transport-https \
  ca-certificates \
  chrony \
  cloud-init \
  conntrack \
  curl \
  gnupg2 \
  jq \
  nfs-common \
  nfs-kernel-server \
  software-properties-common \
  socat \
  git \
  jq \
  mdadm \
  nvme-cli \
  pigz \
  python2.7 \
  python \
  python-setuptools \
  unzip \
  wget \
  python3-pip \
  zip
  # awscli-2 \
  # aws-cfn-bootstrap \
  # amazon-ssm-agent \

echo "installing awscli v2..."
arch=$(uname -m)
curl "https://awscli.amazonaws.com/awscli-exe-linux-$arch.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

echo "Checking AWS CLI version..."
aws --version

echo "Installing pip. via getpip.."
curl "https://bootstrap.pypa.io/pip/2.7/get-pip.py" -o "get-pip.py"
sudo python2.7 get-pip.py
rm get-pip.py

echo "installing aws-cfn-bootstrap..."
wget https://amazoncloudwatch-agent.s3.amazonaws.com/debian/${ARCH}/latest/amazon-cloudwatch-agent.deb
sudo dpkg -i -E ./amazon-cloudwatch-agent.deb

# echo "Installing aws-cfn-bootstrap..."
# mkdir aws-cfn-bootstrap-latest
# curl https://s3.amazonaws.com/cloudformation-examples/aws-cfn-bootstrap-latest.tar.gz | tar xz -C aws-cfn-bootstrap-latest --strip-components 1
# pip --version
# pip3 --version
# sudo pip install ./aws-cfn-bootstrap-latest
# cp -f aws-cfn-bootstrap-latest/init/ubuntu/cfn-hup /etc/init.d/ && chmod 0755 /etc/init.d/cfn-hup
# update-rc.d cfn-hup defaults
# service cfn-hup start


# These are some tools that are no longer installed on AL2023 by default
# there may be more modern replacements for these, so they may dissapper
# in a future version of Amazon Linux
sudo apt-get install -yq \
  lsof \
  rsyslog
  # bind-utils \

# sudo dnf -yq groupinstall "Development Tools"

# Install AWS SSM so that we can use it to permit SSH sessions to this host.
echo "Installing Amazon SSM agent...${ARCH} "
curl --output "/tmp/amazon-ssm-agent.deb" \
  "https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/debian_${ARCH}/amazon-ssm-agent.deb"
sudo dpkg --install "/tmp/amazon-ssm-agent.deb"
rm "/tmp/amazon-ssm-agent.deb"


sudo systemctl enable --now amazon-ssm-agent
sudo systemctl enable --now rsyslog
sudo systemctl enable chrony
GIT_LFS_VERSION=3.4.0
echo "Installing git lfs ${GIT_LFS_VERSION}..."
pushd "$(mktemp -d)"
curl -sSL https://github.com/git-lfs/git-lfs/releases/download/v${GIT_LFS_VERSION}/git-lfs-linux-${ARCH}-v${GIT_LFS_VERSION}.tar.gz | tar xz
sudo git-lfs-${GIT_LFS_VERSION}/install.sh
popd

# See https://github.com/goss-org/goss/releases for release versions
GOSS_VERSION=v0.3.23
echo "Installing goss $GOSS_VERSION for system validation..."
sudo curl -L "https://github.com/goss-org/goss/releases/download/${GOSS_VERSION}/goss-linux-${ARCH}" -o /usr/local/bin/goss
sudo chmod +rx /usr/local/bin/goss
sudo curl -L "https://github.com/goss-org/goss/releases/download/${GOSS_VERSION}/dgoss" -o /usr/local/bin/dgoss
sudo chmod +rx /usr/local/bin/dgoss



echo "Adding secrets-download service template..."
sudo cp /tmp/conf/secrets/systemd/secrets-download.service /etc/systemd/system/secrets-download.service
sudo cp /tmp/conf/secrets/secrets-download.sh /usr/local/bin/secrets-download.sh
