# Setting Up Alert Manager on Kubernetes

AlertManager is an opensource alerting system which works with Prometheus Monitoring system. In our last article, we have explained [Prometheus setup on Kubernetes](https://github.com/veeru538/learning_path/blob/master/setup-prometheus-monitoring-on-kubernetes.md).

In this guide, we will cover the Alert Manager setup and its integration with Prometheus.

Note: In this guide, all the Alert Manager Kubernetes objects will be created inside a namespace called monitoring. If you use a different namespace, you can replace it in the YAML files.
Alert Manager on Kubernetes

Alert Manager setup has the following key configurations.

    A config map for Alert Manager configuration
    A config Map for Alert Manager alert templates
    Alert Manager Deployment
    Alert Manager service to access the web UI.

Key Things To Note

Step 1:
    You should have a working Prometheus setup up and running. Follow this tutorial for Prometheus setup ==> Prometheus Setup On Kubernetes.
    
Step 2: 
    Prometheus should have the correct alert manager service endpoint in its config.yaml as shown below. Only then, Prometheus will be able to send the alert to Alert Manager.
    
```
alerting:
   alertmanagers:
      - scheme: http
        static_configs:
        - targets:
          - "alertmanager.monitoring.svc:9093"

```
Step 3: 
   All the alerting rules have to be present on Prometheus config based on your needs. It should be created as part of the Prometheus config map with a file named prometheus.rules and added to the [prometheus-config-map.yaml](https://raw.githubusercontent.com/veeru538/learning_path/master/config-map.yaml)
 in the following way.
 
```
 rule_files:
      - /etc/prometheus/prometheus.rules
```      
      
Step 4: 
   Alerts can be written based on the metrics you receive on Prometheus.
   For receiving emails for alerts, you need to have a valid SMTP host in the alert manager config.yaml (smarthost prameter).                   You can customize the email template as per your needs in the Alert Template config map. 
   We have given the generic template in this guide.
   
### Config Map for Alert Manager Configuration
Alert Manager reads its configuration from a config.yaml file. It contains the configuration of alert template path, email and other alert receiving configuration. In this setup, we are using email and slack receivers. You can have a look at all the supported alert receivers from here.

Create a file named [AlertManagerConfigmap.yaml](https://raw.githubusercontent.com/veeru538/learning_path/master/AlertTemplateConfigMap.yaml) and copy the following contents.


Let’s create the config map using kubectl.

` kubectl create -f AlertManagerConfigmap.yaml `

### Config Map for Alert Template

We need alert templates for all the receivers we use (email, slack etc). Alert manager will dynamically substitute the values and delivers alerts to the receivers based on the template. You can customize these templates based on your needs.

Create a file named [AlertManagerConfigmap.yaml](https://raw.githubusercontent.com/veeru538/learning_path/master/AlertManagerConfigmap.yaml) and copy the contents from this file

Create the configmap using kubectl.

` kubectl create -f AlertTemplateConfigMap.yaml `

### Create a Deployment

In this deployment, we will mount the two config maps we created.

Create a file called [Deployment.yaml](https://raw.githubusercontent.com/veeru538/learning_path/master/Alertmanager-Deployment.yaml) with the following contents.

Create the deployment using kubectl.

` kubectl create -f Deployment.yaml`

Create a Service

We need to expose the alert manager using NodePort or Load Balancer just to access the Web UI. Prometheus will talk to alert manager using the internal service endpoint.

Create a [Service.yaml](https://raw.githubusercontent.com/veeru538/learning_path/master/Alertmanager-service.yaml) file with the following contents.

Create the service using kubectl.

` kubectl create -f Service.yaml`

Now, you will be able to access Alert Manager on Node Port 31000. For example,
http://nodeserverIP:31000


