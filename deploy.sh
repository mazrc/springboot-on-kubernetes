#!/bin/bash

if [[ $# -lt 4 ]] ; then
    echo 'Valid arguments: ./bg-deploy.sh serviceName serviceVersion 192.168.64.2:32000 deploymentName'
    exit 0
fi

SERVICE=$1
VERSION=$2
DEPLOYMENTNAME=$1-$2
REGISTRYIP=$3
K8SDEPLOYMENT=$4
IMAGENAME=${REGISTRYIP}/${DEPLOYMENTNAME}:"registry"

echo "deploying " + ${DEPLOYMENTNAME} + "to " + ${REGISTRYIP}

# Build a new Image
./mvnw spring-boot:build-image -Dspring-boot.build-image.imageName=${IMAGENAME}
echo "Image successfully buit, now deployting it to private registry"
docker push ${REGISTRYIP}/${DEPLOYMENTNAME}
curl ${REGISTRYIP}/v2/_catalog

# Rollout new update
kubectl rollout restart deployment/${K8SDEPLOYMENT}
