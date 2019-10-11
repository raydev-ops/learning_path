# IMPORTANT! 
# 1. During CentOS installation on all hosts, ensure the /var directory is mapped on its own, and has atleast 15GB space (larger for nodes)
# 2. Create a wildcard domain for the master node: *.master.<DOMAIN>

################################################
# PREREQUISITES
################################################

# ensure you're running the latest and greatest of everything
yum update -y
reboot

#install epel but disable the EPEL repository globally so that is not accidentally used during later steps of the installation
yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    sed -i -e "s/^enabled=1/enabled=0/" /etc/yum.repos.d/epel.repo

# install the following base packages
yum install -y  wget git zile nano net-tools docker-1.13.1 \
                bind-utils iptables-services \
                bridge-utils bash-completion \
                kexec-tools sos psacct openssl-devel \
                httpd-tools NetworkManager \
                python-cryptography python2-pip python-devel  python-passlib \
                atomic atomic-openshift-utils java-1.8.0-openjdk-headless

# install extra packages
yum -y --enablerepo=epel install htop byobu ansible pyOpenSSL

# ensure DNS is porperly configured!!!

# enable and start servicesc
systemctl start NetworkManager docker
systemctl enable NetworkManager docker

################################################
# INSTALLATION
################################################

# configure ssh keys for current (Ansible) and add them to other hosts
ssh-keygen
for host in master.<DOMAIN> \
    infra.<DOMAIN> \
    node-1.<DOMAIN> \
    node-2.<DOMAIN>; \
    do ssh-copy-id -i ~/.ssh/id_rsa.pub $host; \
    done

# in case you want to login to hosts by password
export ANSIBLE_HOST_KEY_CHECKING=False

# clone opensift repo
git clone https://github.com/openshift/openshift-ansible.git && \
  cd openshift-ansible && \
  git fetch && \
  git checkout release-3.11 && \
  cd ..

# update hosts file (necessary if you have you have DNS issues)
cat <<EOD > /etc/hosts
127.0.0.1   localhost 
::1         localhost
<IP>		<server_name> <fqdn>
EOD

# create inventory file
touch inventory.ini
cat <<EOD > inventory.ini
[OSEv3:children]
masters
nodes
etcd

[masters]
master.<DOMAIN>

[etcd]
master.<DOMAIN>

[nodes]
master.<DOMAIN> openshift_node_group_name="node-config-master-infra"
node-[1:2].<DOMAIN> openshift_node_group_name="node-config-compute"

[OSEv3:vars]
openshift_additional_repos=[{'id': 'centos-paas', 'name': 'centos-paas', 'baseurl' :'https://buildlogs.centos.org/centos/7/paas/x86_64/openshift-origin311', 'gpgcheck' :'0', 'enabled' :'1'}]

ansible_ssh_user=root
ansible_ssh_pass=1
enable_excluders=False
enable_docker_excluder=False
ansible_service_broker_install=False

containerized=True
os_sdn_network_plugin_name='redhat/openshift-ovs-multitenant'
openshift_disable_check=disk_availability,memory_availability

deployment_type=origin
openshift_deployment_type=origin

template_service_broker_selector={"region":"infra"}
openshift_metrics_image_version="v3.11"
openshift_logging_image_version="v3.11"
openshift_logging_elasticsearch_proxy_image_version="v1.0.0"
openshift_logging_es_nodeselector={"node-role.kubernetes.io/infra":"true"}
logging_elasticsearch_rollout_override=false
osm_use_cockpit=true

openshift_uninstall_images=false
openshift_metrics_install_metrics=false
openshift_logging_install_logging=false

openshift_master_identity_providers=[{'name': 'htpasswd_auth', 'login': 'true', 'challenge': 'true', 'kind': 'HTPasswdPasswordIdentityProvider'}]

openshift_public_hostname=console.master.<DOMAIN>
openshift_master_default_subdomain=apps.master.<DOMAIN>
openshift_master_api_port=8443
openshift_master_console_port=8443
EOD

# playbook fixes
sed -i -e "s/{{ hostvars[inventory_hostname] | certificates_to_synchronize }}/{{ hostvars[inventory_hostname]['ansible_facts'] | certificates_to_synchronize }}/" \
    openshift-ansible/roles/openshift_master_certificates/tasks/main.yml
sed -i -e "s/logging_elasticsearch_rollout_override | bool/logging_elasticsearch_rollout_override | default(False) | bool/" \
    openshift-ansible/roles/openshift_logging_elasticsearch/handlers/main.yml

# install openshift
ansible-playbook -vv -i inventory.ini openshift-ansible/playbooks/prerequisites.yml
ansible-playbook -vv -i inventory.ini openshift-ansible/playbooks/deploy_cluster.yml

# to uninstall
ansible-playbook -vv -i inventory.ini openshift-ansible/playbooks/adhoc/uninstall.yml

# create default user
htpasswd -b /etc/origin/master/htpasswd petra petr@dmin
oc adm policy add-cluster-role-to-user cluster-admin petra

################################################
# STANDALONE INSTALLATIONS
################################################

# to install logging
sed -i -e "s/^openshift_logging_install_logging=False/openshift_logging_install_logging=true/" inventory.ini
ansible-playbook -vv -i inventory.ini openshift-ansible/playbooks/openshift-logging/config.yml
# to install metrics
sed -i -e "s/^openshift_logging_install_metrics=False/openshift_logging_install_metrics=true/" inventory.ini
ansible-playbook -vv -i inventory.ini openshift-ansible/playbooks/openshift-metrics/config.yml

# incase installing logging failed
# just go into the web portal and change the image `openshift/oauth-proxy:v3.9` to `openshift/oauth-proxy:v1.1.0` (or relevant)

# to enable custom dns
# https://docs.openshift.org/latest/admin_guide/disabling_features.html

master-restart api
master-restart controllers

# now login


# To scale up masters
ansible-playbook -vv -i inventory.ini openshift-ansible/playbooks/byo/openshift-master/scaleup.yml
# To scale up nodes
ansible-playbook -vv -i inventory.ini openshift-ansible/playbooks/byo/openshift-node/scaleup.yml

################################################
# INSTALLATION IMAGES
################################################

docker pull docker.io/openshift/origin-node:v3.11
docker pull docker.io/openshift/origin-pod:v3.11
docker pull docker.io/openshift/origin-control-plane:v3.11
docker pull docker.io/openshift/origin-deployer:v3.11
docker pull docker.io/openshift/origin-haproxy-router:v3.11
docker pull docker.io/openshift/origin-docker-registry:v3.11
docker pull docker.io/openshift/origin-web-console:latest
docker pull docker.io/openshift/origin-metrics-hawkular-metrics:v3.11
docker pull docker.io/gluster/gluster-centos:latest
docker pull quay.io/coreos/cluster-monitoring-operator:v0.1.1
docker pull docker.io/heketi/heketi:latest
docker pull quay.io/coreos/prometheus-config-reloader:v0.23.2
docker pull quay.io/coreos/prometheus-operator:v0.23.2
docker pull docker.io/openshift/prometheus-alertmanager:v0.15.2
docker pull docker.io/openshift/prometheus-node-exporter:v0.16.0
docker pull docker.io/openshift/prometheus:v2.3.2
docker pull docker.io/grafana/grafana:5.2.1
docker pull quay.io/coreos/kube-rbac-proxy:v0.3.1
docker pull quay.io/coreos/etcd:v3.2.22
docker pull quay.io/coreos/kube-state-metrics:v1.3.1
docker pull docker.io/openshift/oauth-proxy:v1.1.0
docker pull quay.io/coreos/configmap-reload:v0.0.1

docker pull quay.io/pires/docker-elasticsearch-kubernetes:5.6.2
