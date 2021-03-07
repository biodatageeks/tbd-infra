#!/usr/bin/env bash


# check required env variables before proceeding
: "${TF_VAR_billing_account:?ERROR: Env variable TF_VAR_billing_account not set !!!}"
: "${TF_ADMIN:?ERROR: Env variable TF_ADMIN not set !!!}"
: "${TF_CREDS:?ERROR: Env variable TF_CREDS not set !!!}"

# setup admin project
gcloud projects create ${TF_ADMIN} \
  --set-as-default

gcloud beta billing projects link ${TF_ADMIN} \
  --billing-account ${TF_VAR_billing_account}

gcloud iam service-accounts create terraform \
  --display-name "Terraform admin account"

if [ ! -f ${TF_CREDS} ]; then
  gcloud iam service-accounts keys create ${TF_CREDS} \
    --iam-account terraform@${TF_ADMIN}.iam.gserviceaccount.com
else
  echo "Credential file already exists. Skipping."
fi

gcloud projects add-iam-policy-binding ${TF_ADMIN} \
  --member serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com \
  --role roles/viewer

gcloud projects add-iam-policy-binding ${TF_ADMIN} \
  --member serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com \
  --role roles/storage.admin

gcloud projects add-iam-policy-binding ${TF_ADMIN} \
  --member serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com \
  --role roles/editor

gcloud projects create ${TF_VAR_project_name}
gcloud projects add-iam-policy-binding ${TF_VAR_project_name} \
  --member serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com \
  --role roles/editor

##terraform setup for storing state and conf credentials
gsutil mb -p ${TF_ADMIN} gs://${TF_ADMIN}

cat > config.tf << EOF
terraform {
  backend "gcs" {
     bucket  = "${TF_ADMIN}"
     prefix  = "terraform/state"
  }
  required_providers {
    google = {
      version = ">= 3.50"
      source  = "hashicorp/google"
  }

  google-beta = {
      version = ">= 3.50"
      source  = "hashicorp/google"
    }
  }
}
EOF

gsutil versioning set on gs://${TF_ADMIN}

export GOOGLE_APPLICATION_CREDENTIALS=${TF_CREDS}
export GOOGLE_PROJECT=${TF_VAR_project_name}

#enablple GCP API