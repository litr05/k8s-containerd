#!/bin/bash

# local machine ip address
export K8SHA_IPLOCAL=172.26.133.162

# local machine etcd name, options: etcd1, etcd2, etcd3
export K8SHA_ETCDNAME=kube-master02

# local machine keepalived state config, options: MASTER, BACKUP. One keepalived cluster only one MASTER, other's are BACKUP
export K8SHA_KA_STATE=BACKUP

# local machine keepalived priority config, options: 102, 101,100 MASTER must 102
export K8SHA_KA_PRIO=101

# local machine keepalived network interface name config, for example: eth0
export K8SHA_KA_INTF=ens18

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
export ETCD_VERSION="v3.1.12"


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



# set keepalived config file
mv /etc/keepalived/keepalived.conf /etc/keepalived/keepalived.conf.bak

cp keepalived/check_apiserver.sh /etc/keepalived/

sed \
-e "s/K8SHA_KA_STATE/$K8SHA_KA_STATE/g" \
-e "s/K8SHA_KA_INTF/$K8SHA_KA_INTF/g" \
-e "s/K8SHA_IPLOCAL/$K8SHA_IPLOCAL/g" \
-e "s/K8SHA_KA_PRIO/$K8SHA_KA_PRIO/g" \
-e "s/K8SHA_IPVIRTUAL/$K8SHA_IPVIRTUAL/g" \
-e "s/K8SHA_KA_AUTH/$K8SHA_KA_AUTH/g" \
keepalived/keepalived.conf.tpl > /etc/keepalived/keepalived.conf

echo 'set keepalived config file success: /etc/keepalived/keepalived.conf'

# set nginx load balancer config file
sed \
-e "s/K8SHA_IP1/$K8SHA_IP1/g" \
-e "s/K8SHA_IP2/$K8SHA_IP2/g" \
-e "s/K8SHA_IP3/$K8SHA_IP3/g" \
nginx-lb/nginx-lb.conf.tpl >  /etc/nginx/nginx.conf

echo 'set nginx load balancer config file success: nginx-lb/nginx-lb.conf'

# set kubeadm init config file
sed \
-e "s/K8SHA_HOSTNAME1/$K8SHA_HOSTNAME1/g" \
-e "s/K8SHA_HOSTNAME2/$K8SHA_HOSTNAME2/g" \
-e "s/K8SHA_HOSTNAME3/$K8SHA_HOSTNAME3/g" \
-e "s/K8SHA_IP1/$K8SHA_IP1/g" \
-e "s/K8SHA_IP2/$K8SHA_IP2/g" \
-e "s/K8SHA_IP3/$K8SHA_IP3/g" \
-e "s/K8SHA_IPVIRTUAL/$K8SHA_IPVIRTUAL/g" \
-e "s/K8SHA_TOKEN/$K8SHA_TOKEN/g" \
-e "s/K8SHA_CIDR/$K8SHA_CIDR/g" \
kubeadm-init.yaml.tpl > kubeadm-init.yaml

sed \
-e "s/K8SHA_IPVIRTUAL/$K8SHA_IPVIRTUAL/g" \
kube-ingress/service-nodeport.yaml.tpl > kube-ingress/service-nodeport.yaml


echo 'set kubeadm init config file success: kubeadm-init.yaml'
