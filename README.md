# devops-training

# Kubernetes installation scripts

## Setup loadbalancer
```sh

stream {
    upstream kubernetes {
        server apiserver.lb:6443 max_fails=3 fail_timeout=30s;
    }
server {
        listen 6443;
        listen 443;
        proxy_pass kubernetes;
    }
}

```
## Install containerd
```sh
sudo apt-get update
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
sudo sysctl --system
sudo apt install containerd -y
sudo mkdir /etc/containerd
sudo containerd config default > /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
sudo systemctl restart containerd
```

## Install kubeadm, kubelet, kubectl
```sh
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```
or 
```sh
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl
#sudo curl -L -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg| gpg -o /usr/share/keyrings/kubernetes-archive-keyring.gpg --dearmor
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```

## Init cluster
```sh
kubeadm init --control-plane-endpoint=apiserver.lb:6443 --upload-certs --pod-network-cidr=10.0.1.0/24
```

## Install cni
```sh
helm repo add cilium https://helm.cilium.io/
helm install cilium cilium/cilium --version 1.14.5 --namespace kube-system
```

## Add master node
```sh
  kubeadm join apiserver.lb:6443 --token u9dcvx.jd94adwibo40s5n4 \
        --discovery-token-ca-cert-hash sha256:92ebdd0f098438b9d198127003d9f23ca96bde410e2f950db9b86e5cbfe51a26 \
        --control-plane --certificate-key 9e68dec2f7e545d50c342a84082f41c700f06c729a88b0192f295728441919d2
```

## Add worker node
```sh
kubeadm join apiserver.lb:6443 --token u9dcvx.jd94adwibo40s5n4 \
        --discovery-token-ca-cert-hash sha256:92ebdd0f098438b9d198127003d9f23ca96bde410e2f950db9b86e5cbfe51a26 
```

## Get token list
```sh
kubeadm token list
```

## Create token
```sh
kubeadm token create
```

## Discovery token ca cert hash
```sh
openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | \
openssl dgst -sha256 -hex | sed 's/^.* //'
```

## Upload Certs
```sh
kubeadm init phase upload-certs --upload-certs
```