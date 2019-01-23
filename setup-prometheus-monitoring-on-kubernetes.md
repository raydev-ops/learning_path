# setup prometheus monitoring on kubernetes

###  Create a Namespace

First, we will create a Kubernetes namespace for all our monitoring components. Execute the following command to create a new namespace called monitoring.

` kubectl create namespace monitoring `

You need to assign cluster reader permission to this namespace so that Prometheus can fetch the metrics from kubernetes API’s.

1. Create a file named clusterRole.yaml (https://raw.githubusercontent.com/veeru538/learning_path/master/clusterRole.yaml)


2. Create the role using the following command.

`  kubectl create -f clusterRole.yaml `

### Create a Config Map

We should create a config map with all the prometheus scrape config and alerting rules, which will be mounted to the Prometheus container in /etc/prometheus as prometheus.yaml and prometheus.rules files. The prometheus.yaml contains all the configuration to dynamically discover pods and services running in the kubernetes cluster. prometheus.rules will contain all the alert rules for sending alerts to alert manager.

1. Create a file called config-map.yaml and copy the contents of this file  [config-map.yaml HERE (https://raw.githubusercontent.com/veeru538/learning_path/master/config-map.yaml)]












