#!/bin/bash

kubectl label servicemonitor/prometheus-pushgateway release=prometheus-community --overwrite

kubectl apply -f examples/spark-operator/servicemonitor-spark.yaml

kubectl get svc --no-headers -o custom-columns=":metadata.name" | grep spark-pi-[[:alnum:]]*-driver-svc | xargs -I {} kubectl label svc {} sparkSvc=driver