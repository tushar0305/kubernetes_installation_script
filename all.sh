#######################
# === All Systems === #
#######################
# Ensure system is fully patched
sudo yum -y update

# Disable swap
sudo swapoff -a; sed -i '/swap/d' /etc/fstab
sudo sed -i --follow-symlinks 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/sysconfig/selinux

# Disable default iptables configuration as it will break kubernetes services (API, coredns, etc...)
sudo sh -c "cp /etc/sysconfig/iptables /etc/sysconfig/iptables.ORIG && iptables --flush && iptables --flush && iptables-save > /etc/sysconfig/iptables"
sudo systemctl restart iptables.service

sudo sh -c 'cat >>/etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF'

sudo yum install -y yum-utils device-mapper-persistent-data lvm2

sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

sudo yum install -y docker-ce-19.03.12 

sudo systemctl enable --now docker

# Add the Kubernetes Repository
sudo sh -c 'cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
       https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF'


# Install Kubernetes
sudo yum -y install kubelet kubeadm kubectl

# Enable kubectl bash-completion
sudo yum -y install bash-completion
source <(kubectl completion bash)
echo "source <(kubectl completion bash)" >> ~/.bashrc

# Enable docker and kubelet services
sudo systemctl enable docker.service
sudo systemctl enable kubelet.service

# reboot
sudo reboot

# Check what cgroup driver that docker is using
sudo docker info | grep -i cgroup

