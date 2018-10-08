#!/bin/bash


# local machine etcd name, options: etcd1, etcd2, etcd3
export K8SHA_ETCDNAME=kube-master01

#######################################
# all masters settings below must be same
#######################################


# master keepalived virtual ip address
export K8SHA_IPVIRTUAL=172.26.133.160

# master01 ip address
export K8SHA_IP1=172.26.133.161

# master02 ip address
export K8SHA_IP2=172.26.133.162

# master03 ip address
export K8SHA_IP3=172.26.133.163


# master01 hostname
export K8SHA_HOSTNAME1=kube-master01

# master02 hostname
export K8SHA_HOSTNAME2=kube-master02

# master03 hostname
export K8SHA_HOSTNAME3=kube-master03

# keepalived auth_pass config, all masters must be same
export K8SHA_KA_AUTH=56cf8dd754c90194d1600c483e10abfr

#etcd tocken:
export ETCD_TOKEN=9489bf67bdfe1b3ae077d6fd9e7efefd

# kubernetes cluster token, you can use 'kubeadm token generate' to get a new one
export K8SHA_TOKEN=535tdi.utzk5hf75b04ht8l


# kubernetes CIDR pod subnet, if CIDR pod subnet is "10.244.0.0/16" please set to "10.244.0.0\\/16"
export K8SHA_CIDR=10.244.0.0\\/16

#etcd version
export ETCD_VERSION="v3.1.24"


##############################
# please do not modify anything below
##############################

# config etcd cluster
touch /etc/etcd.env
echo "PEER_NAME=$K8SHA_ETCDNAME" > /etc/etcd.env
echo "PRIVATE_IP=$K8SHA_IPLOCAL" >> /etc/etcd.env

sed \
-e "s/K8SHA_IPLOCAL/$K8SHA_IPLOCAL/g" \
-e "s/K8SHA_IP1/$K8SHA_IP1/g" \
-e "s/K8SHA_IP2/$K8SHA_IP2/g" \
-e "s/K8SHA_IP3/$K8SHA_IP3/g" \
-e "s/K8SHA_ETCDNAME/$K8SHA_ETCDNAME/g" \
-e "s/K8SHA_HOSTNAME1/$K8SHA_HOSTNAME1/g" \
-e "s/K8SHA_HOSTNAME2/$K8SHA_HOSTNAME2/g" \
-e "s/K8SHA_HOSTNAME3/$K8SHA_HOSTNAME3/g" \
etcd_local/etcd.service.tpl > /etc/systemd/system/etcd.service


# set kubeadm init config file
sed \
-e "s/K8SHA_HOSTNAME1/$K8SHA_HOSTNAME1/g" \
-e "s/K8SHA_HOSTNAME2/$K8SHA_HOSTNAME2/g" \
-e "s/K8SHA_HOSTNAME3/$K8SHA_HOSTNAME3/g" \
-e "s/K8SHA_IP1/$K8SHA_IP1/g" \
-e "s/K8SHA_IP2/$K8SHA_IP2/g" \
-e "s/K8SHA_IP3/$K8SHA_IP3/g" \
-e "s/K8SHA_TOKEN/$K8SHA_TOKEN/g" \
-e "s/K8SHA_CIDR/$K8SHA_CIDR/g" \
kubeadm-init.yaml.tpl > kubeadm-init.yaml
