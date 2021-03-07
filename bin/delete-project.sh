#!/usr/bin/env bash

for project in ${TF_VAR_project_name} ${TF_ADMIN} ;
do
  gcloud projects delete $project
done