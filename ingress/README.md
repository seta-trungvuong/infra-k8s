# How to install and implement K8s Ingress (Cilium class), MetalLB, Nginx reverse proxy

## Enable ingressController of Cilium
Guide: https://docs.cilium.io/en/stable/network/servicemesh/ingress/#installation

```
helm upgrade cilium cilium/cilium --version 1.14.5 \
    --namespace kube-system \
    --reuse-values \
    --set ingressController.enabled=true \
    --set ingressController.loadbalancerMode=dedicated
kubectl -n kube-system rollout restart deployment/cilium-operator
kubectl -n kube-system rollout restart ds/cilium
```

## Install MetalLB
MetalLB hooks into your Kubernetes cluster, and provides a network load-balancer implementation. In short, it allows you to create Kubernetes services of type `LoadBalancer` in clusters that don’t run on a cloud provider, and thus cannot simply hook into paid products to provide load balancers.

#### MetalLB Installation
Install as MetalLB guide: https://metallb.universe.tf/installation/

#### Add MetalLB IPAddressPool
```
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: production
  namespace: metallb-system
spec:
# your private IPv4s range of worker servers then we can expose the public IP to the internet later 
  addresses:
  - 172.31.23.169/32
```

#### Add MetalLB L2 Advertisement
```
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: external
  namespace: metallb-system
spec:
  ipAddressPools:
  - production
```

## Apply Cilium K8s Ingress for services
```
kubectl apply -f infra/ingress/training-ingress.yaml
```

## Add SSL certificate
Add your .pem and .key file to path `/etc/ssl/`

## Setup Nginx reverse proxy
Update the default-sites-enabled server
```
sudo nano /etc/nginx/sites-enabled/default
```

Then clean all the content of `/etc/nginx/sites-enabled/default` and replace to following
```
server {
        listen 80 default_server;
        listen [::]:80 default_server;

        listen 443 default_server ssl;
        listen [::]:443 default_server;

	    ssl_certificate /etc/ssl/test-devops4all.pem; # your .pem file 
	    sl_certificate_key /etc/ssl/test-devops4all.key; # your .key file

        root /var/www/html;

        # Add index.php to the list if you are using PHP
        index index.html index.htm index.nginx-debian.html;

        server_name dotnet.devops4all.co nodejs.devops4all.co; # your domain

        location / {
		proxy_pass http://172.31.23.169/; # the server to reverse
		proxy_http_version 1.1;
                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;		
                # First attempt to serve request as file, then
                # as directory, then fall back to displaying a 404.
                #try_files $uri $uri/ =404;
        }
}
```