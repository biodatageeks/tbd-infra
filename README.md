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

```

## How to setup project

### Authenticate using your google account
```
gcloud auth login

```

### Get your billing account

```
➜  tbd-infra git:(feature/init-cicd) ✗ gcloud beta billing accounts list
You do not currently have this command group installed.  Using it 
requires the installation of components: [beta]


Your current Cloud SDK version is: 308.0.0
Installing components from version: 308.0.0

┌─────────────────────────────────────────────┐
│     These components will be installed.     │
├──────────────────────┬────────────┬─────────┤
│         Name         │  Version   │   Size  │
├──────────────────────┼────────────┼─────────┤
│ gcloud Beta Commands │ 2019.05.17 │ < 1 MiB │
└──────────────────────┴────────────┴─────────┘

For the latest full release notes, please visit:
  https://cloud.google.com/sdk/release_notes

Do you want to continue (Y/n)?  Y
╔════════════════════════════════════════════════════════════╗
╠═ Creating update staging area                             ═╣
╠════════════════════════════════════════════════════════════╣
╠═ Installing: gcloud Beta Commands                         ═╣
╠════════════════════════════════════════════════════════════╣
╠═ Creating backup and activating new installation          ═╣
╚════════════════════════════════════════════════════════════╝

Performing post processing steps...done.                                                                                                                                                                               

Update done!

Restarting command:
  $ gcloud beta billing accounts list

API [cloudbilling.googleapis.com] not enabled on project 
[826258521081]. Would you like to enable and retry (this will take a 
few minutes)? (y/N)?  y

Enabling service [cloudbilling.googleapis.com] on project [826258521081]...
Operation "operations/acf.p2-826258521081-9ea7b39b-9405-4cee-b5bf-ba1d336ef5dc" finished successfully.
ACCOUNT_ID            NAME                      OPEN  MASTER_ACCOUNT_ID
011D36-51D2BA-441848  Big data in data science  True
01D2ED-6D5A86-BF0B57  My Billing Account        True

```

### Export env variables
Once you have your organization and billing account as well group id set the necessary env variables, e.g.:
```
export GROUP_ID=998
export TF_VAR_billing_account=01D2ED-6D5A86-BF0B57
export TF_ADMIN=tbd-group-${GROUP_ID}-admin
export TF_CREDS=~/.config/gcloud/tbd-admin.json
export TF_VAR_project_name=tbd-$(openssl rand -base64 32  | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z]*//g' | cut -c1-8)
export TF_VAR_location=europe-west2-b
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
➜ kubectl get nodes
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



## Verify Kubernetes Spark Operator
```
kubectl apply -f examples/spark-operator/spark-pi.yaml
#get logs
kubectl get sparkapplications spark-pi -o=yaml
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