```bash
export IMAGE_TAG=0.1.3
export SEMESTER=tbd
export GROUP_ID=${SEMESTER}-devel
export PROJECT_DIR=$HOME/tbd/project
export APP_DIR=/Users/mwiewior/research/git/tbd-example-project ### change it so that it points to your cloned project repo\n
export TF_VAR_billing_account=0139AC-53EC0E-245F75   ### copied from billing tab\n
export TF_VAR_location=europe-west1 ### St. Ghislain, Belgium\n
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
    
#inside container
terraform init  
#observe your infra DAG
terraform plan -var-file=env/dev.tfvars -var 'max_node_count=3'
#deploy it if you fully understand the execution plan displayed!
# Warning!: Time needed for cluster setup: approx. 10 mins
terraform apply -var-file=env/dev.tfvars -var 'max_node_count=3'

#debuging
export TF_LOG=trace
```