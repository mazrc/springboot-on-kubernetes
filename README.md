## Spring Boot Microservice on MicroK8s

### Generate Spring Boot Application 

`curl https://start.spring.io/starter.tgz -d artifactId=k8s-demo-app -d name=k8s-demo-app -d packageName=services.objex.demo -d dependencies=web,actuator -d javaVersion=11 | tar -xzf -`


### Add a RestController
Modify K8sDemoApplication.java and add a @RestController


`package services.objex.demo;`

`import org.springframework.boot.SpringApplication;`
`import org.springframework.boot.autoconfigure.SpringBootApplication;`
`import org.springframework.web.bind.annotation.GetMapping;`
`import org.springframework.web.bind.annotation.RestController;`

`@SpringBootApplication`
`@RestController`
`public class K8sDemoAppApplication {`

	public static void main(String[] args) {
		SpringApplication.run(K8sDemoAppApplication.class, args);
	}

	@GetMapping("/")
	public String hello() {
		return "Hello World";
	}
`}`

### Test the app
```
./mvnw spring-boot:run
curl http://localhost:8080; echo
```

And Actuator:

`
curl localhost:8080/actuator | jq .
`

### Build and deploy Docker image
`
./mvnw spring-boot:build-image
`

Test docker image:

`
./mvnw spring-boot:build-image -Dspring-boot.build-image.imageName=192.168.64.2:32000/k8s-demo-app:registry
`

`
docker push 192.168.64.2:32000/k8s-demo-app
`

List images pushed to docker:

`
 curl 192.168.64.2:32000/v2/_catalog
`

### Create K8s Configuration and deploy the app
```
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: k8s-demo-app
  name: k8s-demo-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: k8s-demo-app
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: k8s-demo-app
    spec:
      containers:
        - image: localhost:32000/k8s-demo-app:registry
          name: k8s-demo-app
          resources: {}
status: {}
---
apiVersion: v1
kind: LoadBalancer
metadata:
  creationTimestamp: null
  labels:
    app: k8s-demo-app
  name: k8s-demo-app
spec:
  ports:
    - name: 80-8080
      port: 80
      protocol: TCP
      targetPort: 8080
  selector:
    app: k8s-demo-app
  type: ClusterIP
status:
  loadBalancer: {}
```

Deploy the application:

`
kubectl apply -f deployment.yaml;
`

### Test the App on K8s

To access the app we can use kubectl port-forward

`
kubectl port-forward service/k8s-demo-app 8080:80
curl http://127.0.0.1:8080
`

### Using Metallb LoadBalancer on on MicroK8s
Enable Metallb on MicroK8s:

`
microk8s enable metallb:192.168.64.7-192.168.64.15
`

On private cluster we have to manually assign the IP:

```
kubectl patch service k8s-demo-app -p '{"spec": {"type": "LoadBalancer", "externalIPs":["192.168.64.7"]}}'
```

Your microservice should be available on the IP address without port forwarding:

`
curl http://192.168.64.7; echo
`

### Deploy Kubernetes deployment
kubectl apply -f ./k8s/deployment.yaml

#### Update deployment with newer image
./deploy.sh demo beta1 192.168.64.2:32000
