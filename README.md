# TBD - infrastructure setup

## How to install required tools

### MacOS
```
brew install terraform
brew install kubectl
brew install helm
```
### Linux (deb-based distro, e.g. Ubuntu)
```
# starting in clean Ubuntu distribution
docker run --rm -it ubuntu:20.04

## install necessary OS tools && setup env variables
export TZ=Europe/Warsaw &&
ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone &&
apt -y update &&
apt -y upgrade &&
apt install -y sudo &&
sudo apt install -y curl gnupg lsb-release software-properties-common apt-transport-https ca-certificates pwgen


## install Terraform
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add - && 
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" &&
sudo apt install -y terraform &&
terraform -help

## install Helm 
curl https://baltocdn.com/helm/signing.asc | sudo apt-key add - &&
echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list &&
sudo apt -y update &&
sudo apt install -y helm &&
helm -h

## install kubectl
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg &&
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list &&
sudo apt -y update &&
sudo apt install -y kubectl &&
kubectl -h

## install gcloud 
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list &&
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - &&
sudo apt -y update &&
sudo apt install -y google-cloud-sdk &&
gcloud --help | head
```

# How to setup project

## Formal steps with Google Cloud Console (Terms of Service & Billing)
Log in on Google console https://console.cloud.google.com/ and accept Terms Of Service.

Go to https://console.cloud.google.com/edu and enter YOUR data and coupon code. Accept terms of services.
Go to Billing tab. -> There should be added new Billing Account (Billing Account for Education)

## Setup Google Account in container
In docker container:

```
# initialization
gcloud init 

## nastąpi prosba o zalogowanie. Nalezy postapic zgodnie z instrukcjami. Tzn:
## Przekleic link do przegladarki, zalogowac sie, zezwolic na uzytkownika Google SDK. Przekleic kod weryfikujacy z przegladarki do terminala.

## nastąpi sugestia stworzenia projektu. Nie tworzymy go narazie.

# check billing account 
gcloud beta billing accounts list

# possible output
ACCOUNT_ID            NAME                           OPEN  MASTER_ACCOUNT_ID
014BE5-EF2B99-3EA413  Billing Account for Education  True

```

### Export env variables
Once you have your organization and billing account as well group id set the necessary env variables, e.g.:
```
export RAND_NAME=$(pwgen -1 -0 -A)
export GROUP_ID=$RAND_NAME
export TF_VAR_billing_account=014BE5-EF2B99-3EA413  # the one listed by gcloud beta billing accounts list
export TF_ADMIN=tbd-group-${RAND_NAME}-admin
export TF_CREDS=~/.config/gcloud/tbd-admin.json
export TF_VAR_project_name=tbd-${RAND_NAME}
export TF_VAR_location=europe-west3
export TF_VAR_machine_type=e2-standard-2
```

### Create projects
```
bin/create-project.sh
export GOOGLE_APPLICATION_CREDENTIALS=${TF_CREDS}
export GOOGLE_PROJECT=${TF_VAR_project_name}
terraform init
terraform plan -var-file=env/dev.tfvars
terraform apply -var-file=env/dev.tfvars
```

## Connect to cluster
```
gcloud container clusters get-credentials tbd-gke-cluster --zone ${TF_VAR_location} --project ${TF_VAR_project_name}

kubectl get nodes
NAME                                             STATUS   ROLES    AGE   VERSION
gke-tbd-gke-cluster-tbd-lab-pool-55bcfa4e-8zmq   Ready    <none>   49m   v1.18.12-gke.1210

```

## Verify Kubernetes Spark Operator
```
kubectl apply -f examples/spark-operator/spark-py-pi.yaml
#get logs
kubectl get sparkapplications pyspark-pi -o=yaml
```


## Delete infrastructure
```
terraform destroy -var-file=env/dev.tfvars
```

## Troubleshooting
In case of errors related to missing kubernetes provider in terraform - please try to reauthenticate:
```
gcloud container clusters get-credentials tbd-gke-cluster --zone ${TF_VAR_location} --project ${TF_VAR_project_name}
```