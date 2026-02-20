sudo su
cd

apt-get update && apt-get upgrade -y

apt install curl apt-transport-https \
git wget software-properties-common \
lsb-release ca-certificates socat

swapoff -a

modprobe overlay
modprobe br_netfilter

cat << EOF | tee /etc/sysctl.d/kubernetes.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

sysctl --system

mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
| gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) \
signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | \
tee /etc/apt/sources.list.d/docker.list

apt-get update && apt-get install containerd.io -y

containerd config default | tee /etc/containerd/config.toml

sed -e 's/SystemdCgroup = false/SystemdCgroup = true/g' \
-i /etc/containerd/config.toml

systemctl restart containerd

mkdir -p -m 755 /etc/apt/keyrings

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key \
| gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] \
https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /" | \
tee /etc/apt/sources.list.d/kubernetes.list

apt-get update
apt-get install -y kubeadm=1.33.1-1.1 \
kubelet=1.33.1-1.1 kubectl=1.33.1-1.1

apt-mark hold kubelet kubeadm kubectl

hostname -I