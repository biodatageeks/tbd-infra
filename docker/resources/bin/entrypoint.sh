#!/usr/bin/env bash

cat << EOF

████████ ██████  ██████ 
   ██    ██   ██ ██   ██ 
   ██    ██████  ██   ██ 
   ██    ██   ██ ██   ██ 
   ██    ██████  ██████  
                        

EOF


# check required env variables before proceeding
: "${GROUP_ID:?ERROR: Env variable GROUP_ID not set !!!}"
: "${TF_VAR_billing_account:?ERROR: Env variable TF_VAR_billing_account not set !!!}"
: "${TF_VAR_location:?ERROR: Env variable TF_VAR_location not set !!!}"
: "${TF_VAR_zone:?ERROR: Env variable TF_VAR_zone not set !!!}"
: "${TF_VAR_machine_type:?ERROR: Env variable TF_VAR_machine_type not set !!!}"



mkdir -p $SECRETS_DIR
export TF_ADMIN=tbd-group-${GROUP_ID}-admin
export TF_CREDS=$SECRETS_DIR/tbd-admin.json
export TF_VAR_project_name=tbd-${GROUP_ID}
export GOOGLE_APPLICATION_CREDENTIALS=${TF_CREDS}
export GOOGLE_PROJECT=${TF_VAR_project_name}

echo "Starting TBD container..."
echo "=========================="
echo "GROUP_ID: ${GROUP_ID}"
echo "GOOGLE_PROJECT: ${GOOGLE_PROJECT}"
echo "GOOGLE_APPLICATION_CREDENTIALS: ${GOOGLE_APPLICATION_CREDENTIALS}"
echo "Billing acount: ${TF_VAR_billing_account}"
echo "Location: ${TF_VAR_location}"
echo "Zone: ${TF_VAR_zone}"
echo "Machine type: ${TF_VAR_machine_type}"
echo "=========================="

source "$HOME/.sdkman/bin/sdkman-init.sh" && sdk use java ${JAVA_VERSION}
source "$HOME/.sdkman/bin/sdkman-init.sh" && sdk use scala ${SCALA_VERSION}
source "$HOME/.sdkman/bin/sdkman-init.sh" && sdk use sbt ${SBT_VERSION}

eval $@


