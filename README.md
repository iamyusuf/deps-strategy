# Kubernetes Deployment Strategies Demo

This repository demonstrates various Kubernetes deployment strategies using a simple Express.js application. Each strategy showcases different approaches to updating applications in Kubernetes while maintaining high availability.

## Application Overview

A simple Express.js application that:
- Displays its current version
- Includes health check endpoints (`/healthz`, `/liveness`, `/readiness`)
- Has configurable readiness delays to simulate initialization time

## Docker Images

Two versions of the application are available:
- `iamyusuf/my-app:v1` - Initial version
- `iamyusuf/my-app:v2` - Updated version

## Deployment Strategies

### 1. Rolling Update

The rolling update strategy gradually replaces pods with new versions, ensuring zero downtime during updates.

**Features:**
- `maxSurge: 1` - Allows creating one additional pod over the desired count during updates
- `maxUnavailable: 0` - Ensures all old pods are kept until new ones are ready
- Uses readiness and liveness probes to ensure traffic only goes to healthy pods

**Usage:**
```bash
kubectl apply -f rolling.yml
```

To update to a new version:
```bash
kubectl set image deployment/app-deployment my-app=iamyusuf/my-app:v2
```

### 2. Blue-Green Deployment

This strategy creates two identical environments (blue and green), with only one serving production traffic at a time.

**Features:**
- Two separate deployments (blue with v1 and green with v2)
- A service that initially points to the blue deployment
- Instantly switch traffic by updating the service to point to green
- Zero downtime as traffic instantly switches once all green pods are ready

**Usage:**
```bash
kubectl apply -f blue-green.yml
```

To switch from blue to green, edit the service selector:
```bash
# Service originally points to blue version
# Update to point to green version
kubectl patch svc my-app-service -p '{"spec":{"selector":{"version":"green"}}}'
```

### 3. Canary Deployment

The canary strategy deploys a new version to a small subset of users before rolling it out to everyone.

**Features:**
- Stable deployment serving most traffic
- Canary deployment receiving a controlled percentage of traffic
- Uses NGINX Ingress Controller annotations for traffic splitting
- Configurable traffic percentage with `nginx.ingress.kubernetes.io/canary-weight`

**Usage:**
```bash
kubectl apply -f canary.yml
```

To adjust the canary traffic percentage:
```bash
kubectl patch ingress my-app-ingress-canary -p '{"metadata":{"annotations":{"nginx.ingress.kubernetes.io/canary-weight":"50"}}}'
```

## Prerequisites

- Kubernetes cluster (Minikube recommended for local testing)
- Docker
- kubectl
- NGINX Ingress Controller enabled
- Hosts file entry for local testing:
  ```
  127.0.0.1 myapp.local
  ```

## Local Setup

1. Start Minikube:
   ```bash
   minikube start
   ```

2. Enable the Ingress addon:
   ```bash
   minikube addons enable ingress
   ```

3. Start the tunnel for Ingress to work locally:
   ```bash
   sudo minikube tunnel
   ```

4. Apply one of the deployment strategies:
   ```bash
   kubectl apply -f rolling.yml
   # or
   kubectl apply -f blue-green.yml
   # or
   kubectl apply -f canary.yml
   ```

5. Access the application:
   ```
   http://myapp.local/
   ```

## Testing Scripts

The repository includes scripts to test each deployment strategy:

- `curl_loop.sh` - Continuously sends requests to show real-time traffic distribution

## Health Checking Endpoints

- `/liveness` - Returns 200 status for liveness probes
- `/readiness` - Returns 200 status after a 2-second delay for readiness probes
- `/healthz` - General health check endpoint

## Directory Structure

```
├── README.md
├── Dockerfile
├── package.json
├── index.js
├── rolling.yml       # Rolling update strategy configuration
├── blue-green.yml    # Blue-Green deployment configuration
├── canary.yml        # Canary deployment configuration
└── curl_loop.sh      # Testing script for deployment strategies
```

## Resources and References

- [Kubernetes Documentation - Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- [Kubernetes Documentation - Services](https://kubernetes.io/docs/concepts/services-networking/service/)
- [NGINX Ingress Controller Annotations](https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/annotations/)

## License

ISC
