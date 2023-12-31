#!/usr/bin/env bash

echo -e "\nAtualizando o sistema...\n"
apt update && apt upgrade -y && apt install curl wget apt-transport-https software-properties-common gnupg2 ca-certificates lsb-release -y

echo -e "\nConfigurando Containerd...\n"
mkdir -m 0755 -p /etc/apt/keyrings && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

echo -e "\nInstalando Containerd...\n"
apt update && apt install containerd.io -y
mkdir -p /etc/containerd && containerd config default | tee /etc/containerd/config.toml > /dev/null
sed -i "s/SystemdCgroup = false/SystemdCgroup = true/" /etc/containerd/config.toml
systemctl restart containerd && systemctl status containerd
  [ "$?" = "0" ] && echo -e "\nContainerd sucess\n" || echo -e "\nContainerd error\n"

echo -e "\nModulos do kernel...\n"
cat > /etc/sysctl.d/k8s.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

sysctl --system

cat > /etc/modules-load.d/k8s.conf <<EOF
br_netfilter
ip_vs_rr
ip_vs_wrr
ip_vs_sh
nf_conntrack_ipv4
ip_vs
EOF

modprobe overlay && modprobe br_netfilter

echo -e "\n#### --> Instalando Kubernetes...\n"
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list
apt update && apt install -y kubeadm kubelet kubectl
systemctl enable kubelet && systemctl start kubelet && systemctl status kubelet
  [ "$?" = "0" ] && echo -e "\n#### --> Kubernetes sucess\n" || echo -e "\n#### --> Kubernetes error\n"

echo -e "\nFim do Script Worker...\n"