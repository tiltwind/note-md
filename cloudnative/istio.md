<!---
markmeta_author: wongoo
markmeta_date: 2021-12-22
markmeta_title: istio
markmeta_categories: mesh
markmeta_tags: mesh,service-mesh
-->

# Istio

## install istio
```bash

# Download Istio
curl -L https://istio.io/downloadIstio | sh -

wget -t 0 -T 60 -c https://github.com/istio/istio/releases/download/1.12.2/istio-1.12.2-linux-amd64.tar.gz
tar -xvf istio-1.12.2-linux-amd64.tar.gz
cp istio-1.12.2/bin/istioctl /usr/local/bin

minikube start --cpus=4 --memory=4096

# install 
istioctl install --set profile=demo -y

# Add a namespace label to instruct Istio to automatically inject Envoy sidecar proxies when you deploy your application later
kubectl label namespace default istio-injection=enabled

```


## run istio demo

```bash
# Deploy the Bookinfo sample application:
kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml

kubectl get services

kubectl get pods

# Verify everything is working correctly up to this point. Run this command to see if the app is running inside the cluster and serving HTML pages by checking for the page title in the response:
kubectl exec "$(kubectl get pod -l app=ratings -o jsonpath='{.items[0].metadata.name}')" -c ratings -- curl -sS productpage:9080/productpage | grep -o "<title>.*</title>"

# <title>Simple Bookstore App</title>

# Associate this application with the Istio gateway
kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml

# Ensure that there are no issues with the configuration:
istioctl analyze

# Set the ingress ports:
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
echo "$INGRESS_PORT"

export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}')
echo "$SECURE_INGRESS_PORT"

# Set the ingress IP:
export INGRESS_HOST=$(minikube ip)
echo "$INGRESS_HOST"

```

start minikube tunnel in new window:
```bash
# Run this command in a new terminal window to start a Minikube tunnel that sends traffic to your Istio Ingress Gateway:
su - kube
usermod -aG wheel kube
minikube tunnel

````

browse the demo page:
```bash
# Set GATEWAY_URL:
export GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT
echo "$GATEWAY_URL"

# port forward
socat tcp-listen:8000,reuseaddr,fork tcp:$GATEWAY_URL

# local external host
export LOCAL_EXTERNAL_HOST=10.225.46.24:8000

echo "http://$LOCAL_EXTERNAL_HOST/productpage"
# Paste the output from the previous command into your web browser and confirm that the Bookinfo product page is displayed.
```

view dashboard:
```bash

kubectl apply -f samples/addons
kubectl rollout status deployment/kiali -n istio-system

# request to generate trace data
for i in $(seq 1 100); do curl -s -o /dev/null "http://$GATEWAY_URL/productpage"; done

istioctl dashboard kiali

# port forward
socat tcp-listen:8000,reuseaddr,fork tcp:127.0.0.1:20001

# browser http://10.225.46.24:8000 to see dashboard
```

## uninstall istio

```bash
kubectl delete -f samples/addons
istioctl manifest generate --set profile=demo | kubectl delete --ignore-not-found=true -f -
istioctl tag remove default

# The istio-system namespace is not removed by default. 
# If no longer needed, use the following command to remove it:
kubectl delete namespace istio-system

# The label to instruct Istio to automatically inject Envoy sidecar proxies is not removed by default. 
# If no longer needed, use the following command to remove it:
kubectl label namespace default istio-injection-

minikube stop
```

## reference

- https://istio.io/latest/docs/setup/getting-started/


## History

- 2021-12-22, first version