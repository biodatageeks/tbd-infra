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


## Login to grafana
```
#get admin user password
kubectl get secret prometheus-community-grafana -o jsonpath='{.data}' -n default \
| jq -r '."admin-password"' | base64 --decode
```

## Import grafana dashboards
https://grafana.com/grafana/dashboards/6417
https://grafana.com/grafana/dashboards/7890

## Setup Spark monitoring
```
bin/spark-monitoring.sh
```


## Verify Kubernetes Spark Operator
```
kubectl apply -f examples/spark-operator/spark-py-pi.yaml
#get logs
kubectl get sparkapplications pyspark-pi -o=yaml
```

## Verify sparkctl
```
sparkctl list

bash-3.2$ sparkctl list
+----------+---------+----------------+-----------------+
|   NAME   |  STATE  | SUBMISSION AGE | TERMINATION AGE |
+----------+---------+----------------+-----------------+
| spark-pi | RUNNING | 3m             | N.A.            |
+----------+---------+----------------+-----------------+


bash-3.2$ watch sparkctl event spark-pi

Every 2.0s: sparkctl event spark-pi                                                                                                                                          MacBook-Pro.local: Sat Mar 13 14:44:57 2021

+------------+--------+----------------------------------------------------+
|    TYPE    |  AGE   |                      MESSAGE                       |
+------------+--------+----------------------------------------------------+
| Normal     | 2m     | SparkApplication spark-pi                          |
|            |        | was added, enqueuing it for                        |
|            |        | submission                                         |
| Normal     | 2m     | SparkApplication spark-pi was                      |
|            |        | submitted successfully                             |
| Normal     | 2m     | Driver spark-pi-driver is                          |
|            |        | running                                            |
| Normal     | 1m     | Executor                                           |
|            |        | spark-pi-e3d282782bd37f2d-exec-1                   |
|            |        | is pending                                         |
| Normal     | 1m     | Executor                                           |
|            |        | spark-pi-e3d282782bd37f2d-exec-2                   |
|            |        | is pending                                         |
| Normal     | 1m     | Executor                                           |
|            |        | spark-pi-e3d282782bd37f2d-exec-1                   |
|            |        | is running                                         |
| Normal     | 15s    | Executor                                           |
|            |        | spark-pi-e3d282782bd37f2d-exec-2                   |
|            |        | is running                                         |
+------------+--------+----------------------------------------------------+

```

## Delete infrastructure
```
#list all resources creates
terraform state list
#destroy
terraform destroy -var-file=env/dev.tfvars

#one reosource
terraform destroy -var-file=env/dev.tfvars -target=module.prometheus.helm_release.prometheus
```

## Troubleshooting
In case of errors related to missing kubernetes provider in terraform - please try to reauthenticate:
```
gcloud container clusters get-credentials tbd-gke-cluster --zone ${TF_VAR_location} --project ${TF_VAR_project_name}
```

## Monitoring K8s and Spark applications

### k9s
```
brew install k9s

 Context: gke_tbd-fcinxird_europe-west2-b_tbd-gke-cluster      <0> all       <a>      Attach     <l>       Logs                                                              ____  __.________        
 Cluster: gke_tbd-fcinxird_europe-west2-b_tbd-gke-cluster      <1> default   <ctrl-d> Delete     <p>       Logs Previous                                                    |    |/ _/   __   \______ 
 User:    gke_tbd-fcinxird_europe-west2-b_tbd-gke-cluster                    <d>      Describe   <shift-f> Port-Forward                                                     |      < \____    /  ___/ 
 K9s Rev: v0.24.2                                                            <e>      Edit       <s>       Shell                                                            |    |  \   /    /\___ \  
 K8s Rev: v1.18.12-gke.1210                                                  <?>      Help       <f>       Show PortForward                                                 |____|__ \ /____//____  > 
 CPU:     47%                                                                <ctrl-k> Kill       <y>       YAML                                                                     \/            \/  
 MEM:     22%                                                                                                                                                                                         
┌──────────────────────────────────────────────────────────────────────────────────────── Pods(default)[12] ─────────────────────────────────────────────────────────────────────────────────────────┐
│ NAME                                                      PF READY RESTARTS STATUS   CPU MEM %CPU/R %CPU/L  %MEM/R  %MEM/L IP            NODE                                             AGE      │
│ alertmanager-prometheus-community-kube-alertmanager-0     ●  2/2          0 Running    2  13      2    n/a       5     n/a 10.124.7.12   gke-tbd-gke-cluster-tbd-lab-pool-5094dce6-zsxj   26h      │
│ prometheus-community-grafana-5c54dcfd6b-rbxbl             ●  2/2          0 Running    1  87    n/a    n/a     n/a     n/a 10.124.7.5    gke-tbd-gke-cluster-tbd-lab-pool-5094dce6-zsxj   26h      │
│ prometheus-community-kube-operator-7c654864cf-2xztw       ●  1/1          0 Running    3  25    n/a    n/a     n/a     n/a 10.124.7.2    gke-tbd-gke-cluster-tbd-lab-pool-5094dce6-zsxj   26h      │
│ prometheus-community-kube-state-metrics-7cf56cd4b8-gk2p8  ●  1/1          0 Running    3   9    n/a    n/a     n/a     n/a 10.124.7.3    gke-tbd-gke-cluster-tbd-lab-pool-5094dce6-zsxj   26h      │
│ prometheus-community-prometheus-node-exporter-8268b       ●  1/1          0 Running    5   5    n/a    n/a     n/a     n/a 10.154.0.21   gke-tbd-gke-cluster-tbd-lab-pool-5094dce6-zsxj   26h      │
│ prometheus-community-prometheus-node-exporter-ljqff       ●  1/1          0 Running    1   4    n/a    n/a     n/a     n/a 10.154.0.23   gke-tbd-gke-cluster-tbd-lab-pool-5094dce6-4q0v   22m      │
│ prometheus-prometheus-community-kube-prometheus-0         ●  2/2          1 Running   18 170     18    n/a     340     n/a 10.124.7.9    gke-tbd-gke-cluster-tbd-lab-pool-5094dce6-zsxj   26h      │
│ prometheus-pushgateway-784f97c864-9pl72                   ●  1/1          0 Running    1   7    n/a    n/a     n/a     n/a 10.124.7.14   gke-tbd-gke-cluster-tbd-lab-pool-5094dce6-zsxj   71m      │
│ spark-operator-6d5686474b-xldbg                           ●  1/1          0 Running    1  10    n/a    n/a     n/a     n/a 10.124.7.10   gke-tbd-gke-cluster-tbd-lab-pool-5094dce6-zsxj   23h      │
│ spark-pi-c5a1a5782be6e5f7-exec-1                          ●  1/1          0 Running  362 318     90     30      35      35 10.124.9.5    gke-tbd-gke-cluster-tbd-lab-pool-5094dce6-4q0v   115s     │
│ spark-pi-c5a1a5782be6e5f7-exec-2                          ●  1/1          0 Running  407 320    101     33      35      35 10.124.9.6    gke-tbd-gke-cluster-tbd-lab-pool-5094dce6-4q0v   115s     │
│ spark-pi-driver                                           ●  1/1          0 Running  496 442    124     99      49      49 10.124.9.4    gke-tbd-gke-cluster-tbd-lab-pool-5094dce6-4q0v   2m25s    │
```

### Prometheus

https://spark.apache.org/docs/latest/monitoring.html