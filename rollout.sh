#!/bin/bash

deployments=$(kubectl get deployments  | grep test | awk '{print $1}')

for deployment in $deployments; do
  kubectl rollout restart deployment/$deployment
done
