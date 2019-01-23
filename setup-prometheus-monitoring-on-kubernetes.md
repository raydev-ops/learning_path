# setup prometheus monitoring on kubernetes

###  Create a Namespace

First, we will create a Kubernetes namespace for all our monitoring components. Execute the following command to create a new namespace called monitoring.

` kubectl create namespace monitoring `

You need to assign cluster reader permission to this namespace so that Prometheus can fetch the metrics from kubernetes API’s.

1. Create a file named  [clusterRole.yaml](https://raw.githubusercontent.com/veeru538/learning_path/master/clusterRole.yaml)


2. Create the role using the following command.

`  kubectl create -f clusterRole.yaml `

### Create a Config Map

We should create a config map with all the prometheus scrape config and alerting rules, which will be mounted to the Prometheus container in /etc/prometheus as prometheus.yaml and prometheus.rules files. The prometheus.yaml contains all the configuration to dynamically discover pods and services running in the kubernetes cluster. prometheus.rules will contain all the alert rules for sending alerts to alert manager.

1. Create a file called config-map.yaml and copy the contents of this file  [config-map.yaml](https://raw.githubusercontent.com/veeru538/learning_path/master/config-map.yaml)

2. Execute the following command to create the config map in kubernetes.
	
` kubectl create -f config-map.yaml -n monitoring `

### Create a Prometheus Deployment

1. Create a file named [prometheus-deployment.yaml](https://raw.githubusercontent.com/veeru538/learning_path/master/prometheus-deployment.yaml)

4. Create a deployment on monitoring namespace using the above file.
	
` kubectl create  -f prometheus-deployment.yaml --namespace=monitoring `

5. You can check the created deployment using the following command.
	
` kubectl get deployments --namespace=monitoring `

### Connecting To Prometheus

You can connect to the deployed Prometheus in two ways.

    Using Kubectl port forwarding
    Exposing the Prometheus deployment as a service with NodePort or a Load Balancer.

We will look at both the options.
Using Kubectl port forwarding

Using kubectl port forwarding, you can access the pod from your workstation using a selected port on your localhost.

1. First, get the Prometheus pod name.

` kubectl get pods --namespace=monitoring `

The output will look like the following.

➜  kubectl get pods --namespace=monitoring
NAME                                     READY     STATUS    RESTARTS   AGE
prometheus-monitoring-3331088907-hm5n1   1/1       Running   0          5m

2. Execute the following command with your pod name to access Prometheus from localhost port 8080.

Note: Replace prometheus-monitoring-3331088907-hm5n1 with your pod name.

` kubectl port-forward prometheus-monitoring-3331088907-hm5n1 8080:9090 -n monitoring `

3. Now, if you access http://localhost:8080 on your browser, you will get the Prometheus home page.
Exposing Prometheus as a Service

To access the Prometheus dashboard over a IP or a DNS name, you need to expose it as kubernetes service.

1. Create a file named [prometheus-service.yaml](https://raw.githubusercontent.com/veeru538/learning_path/master/prometheus-service.yaml) and copy the following contents. We will expose Prometheus on all kubernetes node IP’s on port 30000.

Note: If you are on AWS or Google Cloud, You can use Loadbalancer type, which will create a load balancer and points it to the service.

2. Create the service using the following command.

` kubectl create -f prometheus-service.yaml --namespace=monitoring `










