

# Quick demo script for OpenShift V3

## needed if running on all-in-one node
unset KUBECONFIG

oc login -u demo

oc new-project demo
oc project demo

#oc delete all --all

#ensure git is installed
git --version

oc new-app https://github.com/sudhaker/my-node-app.git -l app=my-node-app
watch oc status

oc expose service my-node-app -l name=my-node-app --hostname=my-node-app.apps.sudhaker.com

oc get pods
oc get svc
oc get route

# scale up pod
oc scale dc/my-node-app --replicas=2
oc scale dc/my-node-app --replicas=5
oc scale dc/my-node-app --replicas=2

# pod auto-recovery
oc get pods
oc delete pod #ID

# re-build
oc start-build bc/my-node-app
oc logs bc/my-node-app

# curl based test
while true; do echo -n "$(date) || "; curl http://my-node-app.apps.sudhaker.com/; sleep 0.2; done

### BlueGreen deployment

oc delete all --all

# deploy version 1.0
oc new-app "https://github.com/sudhaker/my-node-app.git#v1" --name=node-app-v1 -l app=my-node-app

oc expose service node-app-v1 --name=my-node-app -l name=my-node-app --hostname=my-node-app.apps.sudhaker.com

# curl based test
for i in {1..5}; do curl http://my-node-app.apps.sudhaker.com/; done

# deploy version 2.0
oc new-app "https://github.com/sudhaker/my-node-app.git#v2" --name=node-app-v2 -l app=my-node-app

oc edit route my-node-app

# curl based test
for i in {1..5}; do curl http://my-node-app.apps.sudhaker.com/; done

### AB deployment

oc delete route my-node-app
oc delete service node-app-v1
oc delete service node-app-v2

oc create -f ab-node-app-service.json

oc expose service ab-node-app -l app=my-node-app --hostname=ab-node-app.apps.sudhaker.com

oc scale dc/node-app-v1 --replicas=4

oc scale dc/node-app-v2 --replicas=1

# curl based test
for i in {1..12}; do curl http://ab-node-app.apps.sudhaker.com/; done

File: my-node-app-ab-service.json

{
    "kind": "Service",
    "apiVersion": "v1",
    "metadata": {
        "name": "ab-node-app",
        "namespace": "demo",
        "labels": {
            "app": "my-node-app"
        }
    },
    "spec": {
        "ports": [
            {
                "name": "8080-tcp",
                "protocol": "TCP",
                "port": 8080,
                "targetPort": 8080
            }
        ],
        "selector": {
            "app": "my-node-app"
        },
        "sessionAffinity": "None"
    }
}

# A colorful demo

oc new-app https://github.com/sudhaker/node_quotes.git -l app=nodequotes
oc expose service nodequotes -l name=nodequotes --hostname=nodequotes.apps.sudhaker.com
