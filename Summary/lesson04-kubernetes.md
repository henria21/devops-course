# Lesson 4 — Kubernetes
> Source: `Class 4 - kubernetes.pptx` (51 slides) — *DevOps Experts Class 3*

---

## What is Container Orchestration?

Container orchestration manages the lifecycles of containers in large, dynamic environments:
- Provisioning and deployment of containers
- Redundancy and availability of containers
- Scaling up or removing containers to spread load
- Moving containers between hosts when resources are short
- Allocating resources between containers
- External exposure of services to the outside world
- Load balancing and service discovery
- Health monitoring of containers and hosts

### Orchestration Tools
| Tool | Description |
|---|---|
| **Kubernetes** | Most popular orchestration system — manages workloads based on user-defined parameters |
| **Docker Swarm** | Native Docker clustering — turns Docker engines into a single virtual engine |
| **Mesosphere Marathon** | Container orchestration for Apache Mesos |

---

## Why Kubernetes?

- Agile application creation and deployment — easier than VM images
- Continuous development, integration, and deployment with quick rollbacks
- Dev and Ops separation of concerns
- Environmental consistency — runs the same on laptop and in cloud
- Cloud and OS portability — Ubuntu, RHEL, CoreOS, GKE, anywhere
- Application-centric management
- Loosely coupled, distributed, elastic micro-services

---

## Kubernetes Architecture

### Master (Control Plane) Components
| Component | Role |
|---|---|
| **API Server** | Central management point — handles REST operations, all components talk through it |
| **etcd** | Key-value store — maintains cluster state and configuration data |
| **Controller Manager** | Maintains cluster's desired state by managing controllers |
| **Scheduler** | Assigns Pods to nodes based on resource availability |

### Node Components (run on every node)
| Component | Role |
|---|---|
| **Kubelet** | Agent on each node — ensures containers run in Pods as expected |
| **Kube-proxy** | Manages network routing for service discovery and load balancing |
| **Container Runtime** | Software (Docker, containerd) that runs containers |
| **kubectl** | CLI tool to interact with the cluster |

### Communication Flow
- All components communicate with the **API Server** via RESTful HTTP/HTTPS
- `etcd` is the backend database for the API Server
- `Scheduler` watches for unassigned Pods → selects node → informs API Server
- `Kubelet` receives Pod specs from API Server and reports Pod status back
- `Kube-proxy` listens to API Server for service/endpoint updates

---

## kubectl CLI

```bash
minikube start               # Start local cluster
minikube dashboard           # Open web dashboard

kubectl get nodes            # List nodes
kubectl get pods             # List pods
kubectl get deployments      # List deployments
kubectl get services         # List services
kubectl get all              # List everything

kubectl describe pod <name>      # Detailed pod info
kubectl logs <pod-name>          # View pod logs
kubectl exec -it <pod> -- bash   # Shell into pod

kubectl apply -f <file.yaml>     # Apply declarative config
kubectl delete -f <file.yaml>    # Delete from config
```

### Two working modes
- **Declarative** — create YAML files describing the desired state; apply with `kubectl apply`
- **Ad Hoc** — run specific commands directly against the cluster

---

## Pods

- Smallest deployable unit in Kubernetes
- Group of one or more containers with shared storage/network
- All containers in a pod are **co-located** and **co-scheduled**
- Each pod gets a unique IP address within the cluster
- Pod IP is reachable only within the cluster unless externally exposed

```bash
kubectl run nginx --image=nginx:1.15.12-alpine
kubectl run redis --image=redis:5.0.4-alpine
kubectl describe pod redis
kubectl logs redis
```

---

## Pod Networking

### Same Node
- Pods on the same node communicate via **localhost** or loopback interface
- Uses Virtual Ethernet (veth) pairs

### Cross-Node
- Uses **Container Network Interfaces (CNIs)** and software-defined networking
- Virtual network overlay spans the entire cluster
- Pod IP remains reachable regardless of location

### DNS-Based Service Discovery
- Built-in DNS service — services get DNS names
- Pods communicate using service names, not individual pod IPs

### Network Policies
- Define rules for which pods can communicate (by IP, port, protocol)
- Add network segmentation and security

---

## Deployments

A Deployment controller provides **declarative updates** for Pods and ReplicaSets.

### Why use Deployments over bare Pods?
| Feature | Deployment | Bare Pod |
|---|---|---|
| Replica management | ✅ Maintains desired count | ❌ Manual |
| Rolling updates | ✅ Zero-downtime updates | ❌ Not supported |
| Rollbacks | ✅ Automatic or manual | ❌ Not supported |
| Health checks | ✅ Readiness/liveness probes | Limited |
| Self-healing | ✅ Replaces failed pods | ❌ No |

```bash
kubectl create deployment hello-node --image=gcr.io/hello-minikube-zero-install/hello-node
kubectl scale deployment/hello-node --replicas=3
kubectl expose deployment hello-node --type=ClusterIP --port=8080
kubectl describe deployment hello-node

# Rolling update & rollback
kubectl set image deployment/nginx nginx=nginx:1.16 --record
kubectl rollout undo deployment/nginx

# Autoscaling
kubectl autoscale deployment nginx --cpu-percent=50 --min=1 --max=5
```

---

## DaemonSets

Ensures that **all (or some) nodes** run a copy of a Pod.
- As nodes are added → Pods are added automatically
- As nodes are removed → Pods are garbage collected

**Typical uses:**
- Cluster storage daemon on every node
- Log collection daemon on every node
- Node monitoring daemon on every node

---

## Services

An abstraction that defines a logical set of Pods and a policy to access them.

| Service Type | Description |
|---|---|
| **ClusterIP** | Internal only — accessible within cluster |
| **NodePort** | Exposes service on each node's IP at a static port |
| **LoadBalancer** | Exposes service externally via a cloud load balancer |

The set of Pods targeted by a Service is determined by a **Label Selector**.

---

## Declarative YAML Example

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.25
        ports:
        - containerPort: 80
```

```bash
kubectl apply -f deployment.yaml
kubectl apply -f ./    # Apply all YAML files in directory
```

---

## Debugging

```bash
kubectl exec -it <pod-name> -- /bin/bash    # Shell into pod
kubectl logs <pod-name>                      # View logs
kubectl port-forward <pod-name> 8080:80      # Forward port for local access
kubectl describe pod <pod-name>              # Detailed status & events
```

---

## Hands-On: Minikube Lab

```bash
minikube start
kubectl create deployment nginx --image=nginx
kubectl scale deployment nginx --replicas=3
minikube dashboard
minikube service <service-name>

# Advanced
kubectl set image deployment/nginx nginx=nginx:1.16 --record
kubectl rollout undo deployment/nginx
kubectl autoscale deployment nginx --cpu-percent=50 --min=1 --max=5
```

---

## Key Takeaways

1. Kubernetes orchestrates containers at scale — scheduling, healing, scaling, networking
2. The Control Plane (API Server, etcd, Scheduler, Controller Manager) manages the cluster
3. Nodes run Kubelet + Kube-proxy + container runtime
4. **Pods** are the smallest unit; **Deployments** manage Pod lifecycle declaratively
5. **DaemonSets** run one Pod per node (logging, monitoring)
6. **Services** provide stable endpoints and load balancing for Pods
7. Always prefer Deployments over bare Pods in production

---

## Assignment

**Goal:** Deploy a frontend + backend app on Minikube using provided YAML files. CLI only — no Helm, no YAML modifications.

**Provided YAML files (`k8s/` folder):**
- `backend-deployment.yaml` — `nginxdemos/hello` image, port 80, `ClusterIP` service
- `frontend-deployment.yaml` — `nginx:alpine` image, port 80, `NodePort` service

**Parts:**
1. Install `kubectl` and `minikube`; verify versions
2. `minikube start` — verify cluster is running
3. Inspect: `kubectl cluster-info`, `kubectl get nodes`, `kubectl get namespaces`, `kubectl get pods -n kube-system`
4. List all services across namespaces: `kubectl get services -A`
5. Deploy: `kubectl apply -f .` inside `k8s/` directory
6. Verify: `kubectl get deployments/pods/services` — confirm backend and frontend running
7. Access frontend in browser via `minikube service frontend`
8. Inspect: `kubectl describe deployment frontend`, describe pod, view logs
9. Undeploy: `kubectl delete -f .`
10. Verify cleanup: confirm no application pods/deployments remain

**Bonus:** Scale backend; explain why frontend is accessible but backend isn't; explain Deployment vs Pod, Service vs Container.

---

## Student Answers

```bash
# Tool versions
kubectl version --client
# Client Version: v1.34.1

minikube version
# minikube version: v1.37.0

# Cluster running
kubectl cluster-info
# Kubernetes control plane is running at https://127.0.0.1:61744

kubectl get nodes
# NAME       STATUS   ROLES           AGE
# minikube   Ready    control-plane   2d16h

kubectl get services -A
# NAMESPACE   NAME         TYPE        CLUSTER-IP    PORT(S)
# default     kubernetes   ClusterIP   10.96.0.1     443/TCP
# kube-system kube-dns     ClusterIP   10.96.0.10    53/UDP...

# After kubectl apply -f .
kubectl get deployments
# backend    1/1   1   1
# frontend   1/1   1   1

kubectl get pods
# backend-576ccdb8d-4zm9z    1/1  Running
# frontend-7b9bcbbfc4-nc679  1/1  Running

kubectl get services
# backend   ClusterIP   10.109.32.167   80/TCP
# frontend  NodePort    10.110.217.55   80:32489/TCP

# Access frontend
minikube service frontend
# URL: http://127.0.0.1:63077
# Browser shows: "Welcome to nginx!"

# Cleanup
kubectl delete -f .
# deployment.apps "backend" deleted
# deployment.apps "frontend" deleted

kubectl get pods
# Only hello-minikube still running (pre-existing)
```
