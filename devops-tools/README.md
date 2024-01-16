# Kubernetes Jenkins Deployment

## Step 1: Create a Namespace for Jenkins.

```
kubectl apply -f namespace.yaml
```

## Step 2: Create a ServiceAccount

The 'serviceAccount.yaml' creates a 'jenkins-admin' clusterRole, 'jenkins-admin' ServiceAccount and binds the 'clusterRole' to the service account.

The 'jenkins-admin' cluster role has all the permissions to manage the cluster components. You can also restrict access by specifying individual resource actions.

```
kubectl apply -f serviceAccount.yaml
```

## Step 3: Create Volume

Create the volume using kubectl

```
kubectl apply -f volume.yaml
```


## Step 4: Create a Deployment

Create the deployment using kubectl.

```
kubectl apply -f deployment.yaml
```

Check the deployment status.

```
kubectl get deployments -n devops-tools
```

Now, you can get the deployment details using the following command.
```
kubectl describe deployments --namespace=devops-tools
```

## Step 5: Create the Jenkins service

```
kubectl apply -f service.yaml
```

You can get that from the pod logs either from the Kubernetes dashboard or CLI. You can get the pod details using the following CLI command.
```
kubectl get pods --namespace=devops-tools

```


## Step 6: Apply Cilium K8s Ingress for services

```
kubectl apply -f infra/ingress/training-ingress.yaml
```

if it not assign externalIPs automatically we can mapping externalIPs manual

```
cilium-ingress-training-ingress
kubectl patch svc cilium-ingress-training-ingress -n api -p '{"spec": {"type": "LoadBalancer", "externalIPs":["10.148.0.7"]}}'
```

### Add SSL certificate

Add your .pem and .key file to path `/etc/ssl/`

### Setup Nginx reverse proxy

Update the default-sites-enabled server

```
sudo nano /etc/nginx/sites-enabled/default
```

Then clean all the content of `/etc/nginx/sites-enabled/jenkins.devops4all.co` and replace to following

```
server {
        listen 80;
        listen [::]:80;

        listen 443 ssl;
        listen [::]:443 ssl;
        ssl_certificate /etc/ssl/cert.pem;
        ssl_certificate_key /etc/ssl/key.pem;

        server_name team5-jenkins.devops4all.co www.team5-jenkins.devops4all.co;

        root /var/www/html;

        # Add index.php to the list if you are using PHP
        index index.html index.htm index.nginx-debian.html;



        location / {
                proxy_pass http://10.148.0.7; # the server to reverse
                proxy_http_version 1.1;
                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto "https";
                proxy_set_header X-Forwarded-Port "443";        
                # First attempt to serve request as file, then
                # as directory, then fall back to displaying a 404.
                #try_files $uri $uri/ =404;
        }
}
```