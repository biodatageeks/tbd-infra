#!/usr/bin/env bash

INPUT_PROJECT=$1
DEFAULTVALUE="tbd-group-${GROUP_ID}"
PROJECT_ID=${1:-$DEFAULTVALUE}
echo "Logging to GCP and GKE cluster..."
gcloud auth activate-service-account  terraform@${TF_ADMIN}.iam.gserviceaccount.com --key-file=$GOOGLE_APPLICATION_CREDENTIALS
gcloud container clusters get-credentials tbd-gke-cluster --zone ${TF_VAR_zone} --project $PROJECT_ID