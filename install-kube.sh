#!/bin/bash
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl
#sudo curl -L -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg| gpg -o /usr/share/keyrings/kubernetes-archive-keyring.gpg --dearmor
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
