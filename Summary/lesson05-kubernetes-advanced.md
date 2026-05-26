# Lesson 5 — Kubernetes Advanced
> Source: `Kubernetes.docx` (theory notes) — *K8s Deep Dive*

---

## Kubernetes Manifest (YAML) Structure

Every Kubernetes manifest has **4 mandatory top-level keys:**

| Key | Description | Example |
|---|---|---|
| **apiVersion** | Which K8s API family | `v1` or `apps/v1` |
| **kind** | What type of object | `Pod`, `Service`, `Deployment` |
| **metadata** | Identification data | `name: my-app` |
| **spec** | Desired state — what you want | `containers: [...]` |

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-web-server
  labels:
    app: nginx
spec:
  containers:
  - name: nginx-container
    image: nginx:latest
```

> **Note:** For `Namespace`, `spec` is optional (it's just a wrapper). For everything else, `spec` is where the real work happens.

### Custom Resource Definitions (CRD)
You can extend K8s with your own API types. Example: **Cert-Manager** adds `kind: Certificate`. When you apply a `Certificate` manifest, the Cert-Manager controller talks to Let's Encrypt and saves the cert as a Secret.

---

## Labels & Selectors

**Labels** are `key: value` pairs attached to objects for organizing, filtering, and grouping.

```yaml
metadata:
  labels:
    env: production
    tier: frontend
    app: login-service
    version: v1.2.1
```

**Selectors** wire Kubernetes objects together:
- Pods have labels → Service has a `selector` matching those labels → traffic routes automatically

```bash
kubectl get pods -l env=production
kubectl get pods -n dev -l tier=frontend
kubectl label pods my-pod-name status=unstable
```

> Use **Labels** for K8s grouping/selection. Use **Annotations** for human-readable notes.

---

## Static Pods

**Static pods** are managed directly by the **kubelet** (not by the API server or scheduler).

- The kubelet watches `/etc/kubernetes/manifest` — any YAML dropped there starts automatically
- This is how the Control Plane bootstraps itself (API Server, Scheduler are started this way)
- Static pods typically do not have replicas

---

## Deployments → ReplicaSets → Pods

```
Deployment (the big boss)
  └── ReplicaSet v1 (old, scaled to 0 after update)
  └── ReplicaSet v2 (new, scaled to 3)
        └── Pod 1
        └── Pod 2
        └── Pod 3
```

- **Deployment** manages versions and orchestrates rolling updates
- **ReplicaSet** manages the count ("I want 3 pods at all times")
- **Pod** is the actual running workload

During a rolling update, Kubernetes creates a **new ReplicaSet** and slowly scales the new one up while scaling the old one down — enabling zero-downtime updates and instant rollback.

> **Never create bare Pods in production.** Always use Deployments.

---

## StatefulSets

For stateful apps (like databases) that need **permanent identity**:
- If the pod dies and restarts, it comes back with the **same name and same volume**
- Unlike Deployments (which are stateless)

---

## Services & kube-proxy

A Service is a **permanent "Search and Replace" rule** in the Linux kernel (via NAT).

| Type | Description |
|---|---|
| **ClusterIP** | Internal only — virtual IP inside the cluster |
| **NodePort** | Exposes on each node's IP at a static port |
| **LoadBalancer** | Cloud provider external LB (AWS ELB, Azure LB) |

### How kube-proxy works
When a packet arrives destined for a Service IP, the **Linux kernel** intercepts it and rewrites the destination to a real Pod IP — this is **NAT**. kube-proxy maintains these kernel rules by watching the API server.

### Two-layer load balancing
1. **External LB** (cloud) — balances traffic across nodes
2. **kube-proxy** — on each node, routes to the best pod (possibly on another node)

> **Topology-aware routing** — kube-proxy can prefer local pods to save latency and cost (e.g., prefer London DB pod for London requests).

---

## Ingress

Ingress provides **HTTP routing** — routes external traffic to different services based on hostname or path.

- **Requires an Ingress Controller** (nginx, traefik, etc.) — without one, the Ingress rules sit dormant
- One LoadBalancer for many services instead of one LB per service
- Enables URL rewriting, canary deployments, virtual hosting, centralized SSL

---

## ConfigMaps & Secrets

| Object | Purpose |
|---|---|
| **ConfigMap** | Non-sensitive configuration (ports, paths, feature flags) |
| **Secret** | Sensitive data (passwords, API keys, certs) — Base64-encoded |

**Why separate config from images:**
1. One image works in dev/staging/prod — inject config at runtime
2. Images in registries shouldn't contain secrets
3. Config changes don't require a rebuild — update ConfigMap and restart pod (seconds, not minutes)
4. Compliance: separates "who deploys" from "who knows the credentials"

---

## RBAC (Role-Based Access Control)

RBAC enforces the **Principle of Least Privilege** — grant only the minimum permissions required.

- **Namespace-scoped** Roles — permissions stop at the namespace boundary
- **ClusterRole** — cluster-wide permissions
- `kubectl auth can-i get pods --as=system:serviceaccount:dev:app-sa -n dev`

**Why Secrets must be RBAC-protected:**
- Secrets are only Base64-encoded (not encrypted by default) — anyone with `get`/`list` can read plaintext
- RBAC limits blast radius if a pod is compromised
- Service account tokens (cluster-admin) can take over the entire cluster if exposed

---

## Persistent Volumes (PV / PVC)

| Object | Role |
|---|---|
| **PV** (PersistentVolume) | The actual storage provisioned in the cluster |
| **PVC** (PersistentVolumeClaim) | A pod's request for storage — survives pod restarts |

If a pod dies, the new pod claims the same PVC → same data, different pod.

---

## Resource Limits in Production

```yaml
resources:
  requests:
    cpu: "250m"
    memory: "128Mi"
  limits:
    cpu: "500m"
    memory: "256Mi"
```

**Why limits are mandatory:**
- **CPU limit** → throttled (slowed down), not killed
- **Memory limit** → OOMKilled (killed immediately if exceeded)
- Prevents "noisy neighbor" pods from consuming all node resources
- If kubelet runs out of resources, the control plane marks the node `NotReady` → cascade failure
- Required for Cluster Autoscaler to correctly decide when to add nodes

---

## Key kubectl Commands

```bash
# Cluster info
minikube profile list
kubectl cluster-info
kubectl get namespaces
kubectl get pods -n kube-system        # Control plane pods

# Resources
kubectl get pods/deployments/rs/services
kubectl get rs -A                       # All replica sets across namespaces
kubectl get endpoints
kubectl get nodes -o wide

# Apply and debug
kubectl apply -f .                      # Apply all YAML in directory
kubectl describe pod <name>
kubectl logs <pod-name>
kubectl auth can-i get pods --as=<sa>
```

---

## Key Takeaways

1. Every manifest needs `apiVersion`, `kind`, `metadata`, `spec`
2. Labels + Selectors wire objects together — Services find Pods by label selector
3. Deployment → ReplicaSet → Pod; rolling updates use two ReplicaSets for zero downtime
4. kube-proxy implements Services as Linux kernel NAT rules
5. Ingress routes HTTP traffic; requires an Ingress Controller
6. ConfigMap for config, Secrets for credentials — never bake either into images
7. RBAC enforces least privilege; always protect Secrets with RBAC
8. Resource limits are mandatory in production to prevent noisy-neighbor failures

---

## Assignment

**Goal:** Practice Kubernetes advanced concepts — namespaces, deployments, services, Ingress, ConfigMaps, Secrets, and RBAC — with hands-on kubectl exercises.

**Parts:**
1. **Namespaces** — Create `dev` namespace; explain logical vs physical separation; list all namespaces
2. **Bare Pod** — Create a Pod in `dev`; delete it; observe it does NOT self-heal (no controller)
3. **Deployment** — Deploy 3 replicas to `dev`; observe Deployment → ReplicaSet → Pod hierarchy
4. **Scaling + Rolling Update** — Scale to 5; update image tag; observe 2 ReplicaSets during rollout
5. **Services** — Apply ClusterIP, NodePort; explain when to use LoadBalancer
6. **Ingress** — Apply Ingress manifest; explain why it does nothing without an Ingress Controller
7. **ConfigMap & Secret** — Create both; mount as env vars or volume; explain why config stays out of images
8. **RBAC** — Create ServiceAccount; apply Role + RoleBinding; `kubectl auth can-i` verify permissions
9. **Production Thinking** — Add resource `requests` and `limits`; explain why limits are mandatory in production

---

## Student Answers

**Namespaces:**
```bash
kubectl get namespaces
# NAME                   STATUS   AGE
# backend                Active   12d
# default                Active   12d
# dev                    Active   107s
# kube-system            Active   12d
```

**What a namespace is:** Logical isolation — "virtual clusters" within the physical cluster. Resources share the same hardware but are organized separately. Namespace is logical (not physical) because it's enforced by the Kubernetes API, not by hardware.

**Bare Pod behavior:**
```bash
kubectl delete pod demo-pod -n dev
kubectl get pods -n dev
# No resources found in dev namespace.
```
Pod does **not** self-heal — it was not managed by a Deployment/ReplicaSet. It stays dead until the YAML is re-applied.

**Deployment → ReplicaSet → Pod:**
```bash
kubectl get deployments,rs,pods -n dev
# deployment.apps/app-deployment   3/3   3   3
# replicaset.apps/app-deployment-5d879fb8d9   3   3   3
# pod/app-deployment-5d879fb8d9-6c9tb   1/1 Running
# pod/app-deployment-5d879fb8d9-tb7kt   1/1 Running
# pod/app-deployment-5d879fb8d9-wxpkr   1/1 Running
```

**After rolling update (image change):**
```bash
kubectl set image deployment/app-deployment app=nginx:latest -n dev
kubectl get rs -n dev
# app-deployment-5d879fb8d9   0   0   0   (old — scaled down)
# app-deployment-77cf88dc74   5   5   5   (new — active)
```
Kubernetes keeps the old ReplicaSet for rollback. Two ReplicaSets exist during and after a rolling update.

**Why Kubernetes creates a new ReplicaSet during updates:**
- Rolling update: gradually scale new up / old down
- Rollback: keep old ReplicaSet (scaled to 0) ready for instant revert
- Immutable infrastructure: don't patch existing RS, create a clean new one

**Service types:**
- **ClusterIP** — internal only; pods talk to each other
- **NodePort** — expose on every node's IP + port
- **LoadBalancer** — best for production; cloud-managed, provides public IP/DNS

**Ingress without controller:**
Without an Ingress Controller, the Ingress resource is accepted by the API server but completely dormant — no external IP assigned, no traffic routed.

**Why not expose every Service directly (LoadBalancer per service):**
1. Cost — each LB is a billable cloud resource
2. DNS management nightmare — each service gets its own IP
3. Security — wider attack surface, no centralized WAF/SSL
4. No advanced routing — no URL rewriting, canary, virtual hosting

**ConfigMap & Secret — why separate from images:**
1. One image for all environments — inject config at runtime
2. Images in registries shouldn't contain secrets
3. Config changes don't require a rebuild (seconds, not 5–10 min CI/CD cycle)
4. Separation of duties — devs build images, ops controls production credentials
5. Immutability — `v1.2.3` in staging should be identical bytes in production

**Why Secrets need RBAC:**
- Secrets are Base64-encoded (not encrypted by default) — readable instantly
- Service account tokens can give cluster-admin if exposed
- RBAC limits blast radius of a compromised pod to its namespace
- Regulatory compliance (GDPR, PCI DSS) requires audit trails of secret access

**RBAC verification:**
```bash
kubectl auth can-i get pods --as=system:serviceaccount:dev:app-sa -n dev
# yes
```

**Why RBAC is namespace-scoped:**
- Multi-tenancy — Team A can't touch Team B's secrets
- Blast radius reduction — compromised pod trapped in its namespace
- Delegation — cluster admin can grant "team lead" admin of their namespace only

**Resource limits in production:**
```yaml
resources:
  limits:
    cpu: "500m"
    memory: "256Mi"
replicas: 3
strategy:
  type: RollingUpdate
```
Dev needs fewer replicas and lower CPU/memory. Prod needs more for availability and scale.

**Why limits are mandatory:**
- Without CPU limit → one pod starves all others on the node
- Without memory limit → pod with memory leak kills the node → control plane marks node NotReady → cascade failure
- CPU: throttled at limit (not killed). Memory: OOMKilled immediately at limit.
- Cluster Autoscaler needs limits to determine when to provision new nodes
