####################################################################
## INSTALL
####################################################################

echo "deb http://www.apache.org/dist/cassandra/debian 311x main" | tee -a /etc/apt/sources.list.d/cassandra.sources.list && \
  curl https://www.apache.org/dist/cassandra/KEYS | apt-key add - && \
  add-apt-repository ppa:webupd8team/java && \
  apt update 
apt install -y oracle-java8-installer cpufrequtils
apt install -y cassandra

####################################################################
## CONFIGURE
####################################################################

systemctl stop cassandra
rm -rf /var/lib/cassandra/data/system/*
sed -i 's/Test Cluster/cluster-name/g' /etc/cassandra/cassandra.yaml && \
    sed -i 's/- seeds: "127.0.0.1"/- seeds: "hostname-01.local,hostname-03.local,hostname-03.local"/g' /etc/cassandra/cassandra.yaml && \
    sed -i 's/start_rpc: false/start_rpc: true/g' /etc/cassandra/cassandra.yaml && \
    sed -i 's/endpoint_snitch: SimpleSnitch/endpoint_snitch: GossipingPropertyFileSnitch/g' /etc/cassandra/cassandra.yaml && \
    sed -i 's/listen_address: localhost/listen_address: hostname-01.local/g' /etc/cassandra/cassandra.yaml && \
    sed -i 's/rpc_address: localhost/rpc_address: hostname-01.local/g' /etc/cassandra/cassandra.yaml && \
systemctl start cassandra

####################################################################
## TUNE
####################################################################

$ cat <<EOD > /etc/sysctl.conf
net.ipv4.tcp_keepalive_time=60
net.ipv4.tcp_keepalive_probes=3
net.ipv4.tcp_keepalive_intvl=10
net.core.rmem_max=16777216
net.core.wmem_max=16777216
net.core.rmem_default=16777216
net.core.wmem_default=16777216
net.core.optmem_max=40960
net.ipv4.tcp_rmem=4096 87380 16777216
net.ipv4.tcp_wmem=4096 65536 16777216
vm.max_map_count = 1048575
EOD
$ sysctl -p /etc/sysctl.conf

# disable cpu frequency scaling
$ echo 'GOVERNOR="performance"' | sudo tee /etc/default/cpufrequtils
$ systemctl disable ondemand
$ cpufreq-info

# disable numa nodes
$ echo 0 > /proc/sys/vm/zone_reclaim_mode

# set resource limits
$ vi /etc/security/limits.d/cassandra.conf
cassandra - memlock unlimited
cassandra - nofile 100000
cassandra - nproc 32768
cassandra - as unlimited
$ vi /etc/security/limits.conf
root - memlock unlimited
root - nofile 100000
root - nproc 32768
root - as unlimited

# disable swap
$ swapoff --all

# check java hugepages
$ echo never | sudo tee /sys/kernel/mm/transparent_hugepage/defrag

# set consistency
$ 

####################################################################
## USE
####################################################################
node status
watch -n 1 nodetool tpstats

# change replication factor
ALTER KEYSPACE "petra_tools" WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 3 };