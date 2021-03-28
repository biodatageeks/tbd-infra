# TBD - infrastructure setup

# Project environment
![Alt text](doc/diagrams/tbd.png?raw=true "Project environment")
# How to setup project

## Formal steps with Google Cloud Console (Terms of Service & Billing)
Log in on Google console https://console.cloud.google.com/ and accept Terms Of Service.

Go to https://console.cloud.google.com/edu and enter YOUR data and coupon code. Accept terms of services.
Go to Billing tab. -> There should be added new Billing Account (Billing Account for Education)

## How to use a helper Docker image 
Once you have your organization and billing account as well group id set the necessary env variables, e.g.:
```
### setup GROUP_ID and TF_VAR_billing_account properly
export IMAGE_TAG=0.1.3
export SEMESTER=2021l
export GROUP_ID=${SEMESTER}-NNN ## Watch out ! Please use the group id provided by lecturers!
export PROJECT_DIR=$HOME/tbd/project
export TF_VAR_billing_account=NNNNNN-NNNNNN-NNNNNN   ### copied from billing tab
export TF_VAR_location=europe-west1 ### St. Ghislain, Belgium
export TF_VAR_zone=europe-west1-b
export TF_VAR_machine_type=e2-standard-2

mkdir -p $PROJECT_DIR
cd $PROJECT_DIR
docker run --rm -it \
    --name tbd \
    -p 9090:9090 \
    -p 9091:9091 \
    -p 3000:3000 \
    -p 4040:4040 \
    -v $PROJECT_DIR:/home/tbd \
    -e GROUP_ID=$GROUP_ID \
    -e TF_VAR_billing_account=$TF_VAR_billing_account \
    -e TF_VAR_location=$TF_VAR_location \
    -e TF_VAR_zone=$TF_VAR_zone \
    -e TF_VAR_machine_type=$TF_VAR_machine_type \
    biodatageeks/tbd-os:$IMAGE_TAG bash
```
Run above commands whenever you would like to operate with your infrastructure on GCP, incl GKE cluster management.
If you would like to connect to the running container to have multiple sessions, just run:
```
 docker exec -it tbd bash
```

## Setup Google Account in container
(Only when installing/reinstalling cluster)

In docker container:

```
gcloud auth login your.user@gmail.com

```



### Create projects and setup GKE cluster
In a docker container:
```
mkdir -p /home/tbd/git/ && cd /home/tbd/git/
git config --global user.email "your.mail.for.github@nnn.nn"
git config --global user.name "YourName YourSurname"
git clone https://github.com/biodatageeks/tbd-infra.git
cd tbd-infra 

#create GCP projects and service accounts
bin/create-project.sh

#setup GKE and install necessary components
terraform init  
#observe your infra DAG
terraform plan -var-file=env/dev.tfvars -var 'max_node_count=10' -out plan
#deploy it if you fully understand the execution plan displayed!
# Warning!: Time needed for cluster setup: approx. 10 mins
terraform apply "plan"
```

## Connect to GKE cluster
Run this to get access to your GKE cluster once you created it successfully.
```
gcp-login.sh
```
## Sanity checks
```
root@c36be371bc27:/home/git/tbd-infra# kubectl get nodes
NAME                                             STATUS   ROLES    AGE     VERSION
gke-tbd-gke-cluster-tbd-lab-pool-842565a1-p7k0   Ready    <none>   7m14s   v1.18.12-gke.1210


root@c36be371bc27:/home/git/tbd-infra# kubectl get pods
NAME                                                       READY   STATUS    RESTARTS   AGE
alertmanager-prometheus-community-kube-alertmanager-0      2/2     Running   0          84s
prometheus-community-grafana-7f65449cd5-fb8jg              2/2     Running   0          91s
prometheus-community-kube-operator-7c654864cf-bkczd        1/1     Running   0          91s
prometheus-community-kube-state-metrics-7cf56cd4b8-qzf2r   1/1     Running   0          91s
prometheus-community-prometheus-node-exporter-dbstj        1/1     Running   0          91s
prometheus-prometheus-community-kube-prometheus-0          2/2     Running   1          83s
prometheus-pushgateway-758d744f6-fv5kl                     1/1     Running   0          16m
spark-operator-6d5686474b-vh6n7                            1/1     Running   0          114s


```
...if you see the output of the above commands - good job ... it's not the end of the story though ;-)

## Setup port forwarding
### Port forwarding from a docker container
To get port forwarding use `0.0.0.0` bind instead of default `localhost`.
For port forwarding you can use `kubectl` or `k9s` tool.

Example of forwarding Grafana:
```
kubectl port-forward --address 0.0.0.0 $(kubectl get pods -o name | grep grafana) 3000:3000
```

### Monitoring apps ports

- Grafana: 3000
- Prometheus: 9090
- Prometheus gateway: 9091
- Spark UI: 4040

## Login to grafana
Use `admin` as username and get admin password
```
#get admin user password
kubectl get secret prometheus-community-grafana -o jsonpath='{.data}' -n default \
| jq -r '."admin-password"' | base64 --decode && echo ' '
```

## Import grafana dashboards
Please import the following community dashboards
- https://grafana.com/grafana/dashboards/6417
- https://grafana.com/grafana/dashboards/7890
- and the one provided in `monitoring/grafana` folder.

## Verify Kubernetes Spark Operator
```
# create ServiceMonitor
kubectl apply -f examples/spark-operator/service-monitor.yaml

#submit app and turn on monitoring
export APP_NAME=spark-pi
sparkctl delete $APP_NAME
#cleanup old Spark driver service if exists
kubectl get svc --no-headers -o custom-columns=":metadata.name" | grep $APP_NAME-[[:alnum:]]*-driver-svc | xargs -I {} kubectl delete svc {}
kubectl apply -f examples/spark-operator/$APP_NAME.yaml
while [ $(kubectl get svc --no-headers -o custom-columns=":metadata.name" | grep $APP_NAME-[[:alnum:]]*-driver-svc | wc -l) -lt 1 ];
do
echo "Service does not exists yet, waiting 1s"
sleep 1
done
kubectl get svc --no-headers -o custom-columns=":metadata.name" | grep $APP_NAME-[[:alnum:]]*-driver-svc | xargs -I {} kubectl label svc {} sparkSvc=driver

#get logs
kubectl get sparkapplications spark-pi -o=yaml
```

## Verify sparkctl
```
sparkctl list
+----------+---------+----------------+-----------------+
|   NAME   |  STATE  | SUBMISSION AGE | TERMINATION AGE |
+----------+---------+----------------+-----------------+
| spark-pi | RUNNING | 3m             | N.A.            |
+----------+---------+----------------+-----------------+


watch sparkctl event spark-pi

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

sparkctl log -f spark-pi 

Pi is roughly 3.1414334771381114

```

## Verify Grafana metrics
Navigate to grafana and check `Kubernetes - Apache Spark Metrics` dashboard if you can see any metrics of SparkPi app.


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
gcloud container clusters get-credentials tbd-gke-cluster --zone ${TF_VAR_zone} --project ${TF_VAR_project_name}
```

## Monitoring K8s and Spark applications

### Port forwarding from a docker container
To get port forwarding use `0.0.0.0` bind instead of default `localhost`.
For port forwaring you can use `kubectl` or `k9s` tool

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


## (Optional) How to install required tools
Only if you decide NOT to use the provided Docker image.

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