# Развертываение kubernetes HA с containerd
1. Cхема и описание развертывания
![схема развертывания](https://github.com/rjeka/k8s-containerd/blob/master/images/ha.png)

При разворачивании кластера используется keepalived. Keepalived  создает виртуальный IP (VIRTIP) который указывает на один из трех мастеров. 
Если какой либо из мастеров "падает", то keepalived переключит VIRTIP на следующего мастерф, согласно "весу", указанному при настройке keepalived на каждом мастере.<br/>
Работа API сервера kubernetes настроена следующем образом:<br/>
При настройке кластера порт API сервера будет измен с 6443 на 16443.(подробности ниже) На каждом из мастеров развернут nginx, который работает как loadbalancer, слушает порт 16443 и делает upstream по всем трем мастерам на порт 6443 (подробности ниже). <br/>
Данной схемой достигнута повышенная отказоустойчивость c помощью keepalived, а так же с помощью nginx достигнута балансировка между API серверами на мастерах.<br/>

Name            | IP                              |Службы
----------------|---------------------------------|--------------
VIRTIP          | 172.26.133.160                  | kubeadm, kubelet, kubectl, etcd, containerd, nginx, keepalived
kube-master01   | 172.26.133.161                  | kubeadm, kubelet, kubectl, etcd, containerd, nginx, keepalived
kube-master02   | 172.26.133.162                  | kubeadm, kubelet, kubectl, etcd, containerd, nginx, keepalived   
kube-master03   | 172.26.133.163                  | kubeadm, kubelet, kubectl, etcd, containerd, nginx, keepalived
kube-node01     | 172.26.133.164                  | kubeadm, kubelet, kubectl, etcd, containerd, nginx, keepalived
kube-node02     | 172.26.133.165                  | kubeadm, kubelet, kubectl, etcd, containerd, nginx, keepalived
kube-node03     | 172.26.133.166                  | kubeadm, kubelet, kubectl, etcd, containerd, nginx, keepalived

2. Установка kubeadm, kubelet and kubectl и сопутствующие пакеты
Все комманды выполнять из под root
```bash
sudo -i
```
Устаавливаем kubelet and kubectl
```bash
apt-get update && apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
apt-get install -y kubelet kubeadm kubectl unzip tar apt-transport-https btrfs-tools libseccomp2 socat util-linux mc vim keepalived
```
3. Установка conteinerd
```bash
cd /
wget https://storage.googleapis.com/cri-containerd-release/cri-containerd-1.1.0-rc.0.linux-amd64.tar.gz
tar -xvf cri-containerd-1.1.0-rc.0.linux-amd64.tar.gz
```
