# Terraform GCP Organization
- Create a new Google admin project
- Create an admin service account
    - Enable cloudresourcemanager.googleapis.com
    - Grant `roles/resourcemanager.projectCreator` at the Organization level
- Download service account JSON credentials and move to `terraform/admin.gcp.json`

## Creating our root project
We'll start by automating the organizational layout, and bootstrapping the initial resources and the corresponding IAM roles, which will then be used to automate the actual infrastructure.

We'll largely follow Google's [Cloud Foundation Project](https://github.com/
terraform-google-modules/cloud-foundation-fabric/tree/master/organization-bootstrap) here.

```sh
gcloud init
gcloud auth login
gcloud auth application-default login
gcloud auth application-default print-access-token

export GOOGLE_OAUTH_ACCESS_TOKEN=asdfasdf
terraform init
terraform plan
```

## Terraform
```
terraform workspace new prod
terraform workspace select prod
terraform init --var-file= prod.tfvars
terraform plan --var-file= prod.tfvars
terraform apply --var-file= prod.tfvars
```

## Deploy a sample app with Docker + Kubernetes
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

View service logs
```
kubectl logs my-app-service
```

Check service and copy external IP address (LoadBalancer)
```
kubectl get services
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

## Resources
https://itnext.io/deploying-a-node-js-app-to-the-google-kubernetes-engine-gke-d6af1f3a954c




