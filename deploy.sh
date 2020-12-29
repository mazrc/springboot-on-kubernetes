
if [[ $# -lt 4 ]] ; then
    echo 'Valid arguments: ./deploy.sh serviceName serviceVersion 192.168.64.2:32000 k8DeploymentName'
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
# ./mvnw spring-boot:build-image -Dspring-boot.build-image.imageName=${IMAGENAME}
docker load < microservice.tar
docker tag objex/k8s-demo-app:latest  ${IMAGENAME}
echo "Image successfully loaded and tagged, now deploying it to microk8s private registry"
docker push ${IMAGENAME}
curl ${REGISTRYIP}/v2/_catalog

# Rollout new update
kubectl rollout restart deployment/${K8SDEPLOYMENT}
