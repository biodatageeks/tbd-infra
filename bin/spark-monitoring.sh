#!/bin/bash

kubectl label servicemonitor/prometheus-pushgateway release=prometheus-community --overwrite

kubectl apply -f examples/spark-operator/servicemonitor-spark.yaml