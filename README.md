# Terraform GCP Organization

## Creating the root project
We'll start by automating the organizational layout, and bootstrapping the initial resources and the corresponding IAM roles, which will then be used to automate the actual infrastructure.

We'll largely follow Google's [Cloud Foundation Project](https://github.com/terraform-google-modules/cloud-foundation-fabric/tree/master/organization-bootstrap) here.

```sh
gcloud init
gcloud auth login
gcloud auth application-default login
gcloud auth application-default print-access-token

export GOOGLE_OAUTH_ACCESS_TOKEN=<output-from-above>

cd ./root
terraform init
terraform apply
```

## Creating an environment
Once our root project is created, we can use the service account we've created to scaffold a new environment to deploy our app. We'll first want to create a new Terraform workspace, which we'll help us to dynamically select our variables.

```sh
cd ./environment
terraform workspace new prod
terraform workspace select prod

terraform init
terraform apply
```

## Deploying our app with Docker + Kubernetes
Grab Kubectl credentials
```
gcloud container clusters get-credentials <cluster-name> --region <region>
```

Build Docker Image
```
docker build -t gcr.io/<image-tag>/app:v1 .
docker push gcr.io/<image-tag>/app:v1
```

Create deployment and service.
```
kubectl apply -f deployment.yaml --record
```

Check deployment process
```
kubectl get deployments
```

Check pods (containers)
```
kubectl get pods
```

View service or container logs
```
kubectl logs <pod-name> [-c <container-name>]
```

See what's running on a pod
```
kubectl describe pod/<pod-name> -n default
```

Start a remote shell on a running container
```
kubectl exec -it <pod-name> -c <container-name> -- /bin/bash
```

Check service and copy external IP address (LoadBalancer)
```
kubectl get svc
```

Open in your browser this URL
```
http://<external-ip>/encrypt?secret=abc&message=hey

# Encrypt a message with a secret
curl -G '<external-ip>/encrypt' \
-d secret=8650 \
-d message=hey

# Decrypt a message" with a secret
curl -G 'http://localhost:4000/decrypt' \
-d secret=8650 \
-d message=12840030619419b8d8ec4fe61e275d99
```

Tear down the deployment when you're done with it
```
kubectl delete -f deployment.yaml
```

## Resources
https://www.terraform.io/docs/providers/google/
https://cloud.google.com/iam/docs/understanding-roles
https://cloud.google.com/compute/docs/access/iam
https://itnext.io/deploying-a-node-js-app-to-the-google-kubernetes-engine-gke-d6af1f3a954c
https://medium.com/@wynsen/gcp-shared-vpc-network-etc-management-with-terraform-c011d71a1042
