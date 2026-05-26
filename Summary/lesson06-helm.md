# Lesson 6 — Helm: Kubernetes Package Manager
> Source: `Helm_Concepts_Explained_Before_Lab.pptx` (21 slides) + `Helm_Hands_On_Lab_Beginners.pptx` (14 slides)

---

## The Problem with Plain YAML

**Typical plain kubectl workflow:**
1. Write `Deployment` YAML
2. Write `Service` YAML
3. `kubectl apply -f` — works for small setups only

**Problems at scale:**
- Copy-paste between environments (dev/staging/prod)
- Hardcoded values that must be manually changed per environment
- No application-level abstraction
- Difficult upgrades — manual process
- No rollback mechanism

---

## What is Helm?

Helm is a **package manager for Kubernetes**. It packages multiple YAML files into a single deployable unit called a **chart**.

> Helm does **not** replace Kubernetes. YAML remains the foundation.
> Kubernetes never knows Helm exists — Helm renders templates and sends YAML to K8s.

### Helm vs kubectl

| | kubectl | Helm |
|---|---|---|
| Applies | Raw YAML | Rendered templates |
| Release tracking | ❌ | ✅ |
| Versioning | ❌ | ✅ |
| Rollback | ❌ | ✅ |

---

## Helm Architecture

Helm runs **locally**:
1. Reads chart templates + values
2. Renders templates → generates pure YAML
3. Sends YAML to Kubernetes via kubectl

Kubernetes only ever receives plain YAML — it has no awareness of Helm.

---

## Core Concepts

| Term | Meaning |
|---|---|
| **Chart** | Helm package — contains templates, values, metadata |
| **Release** | A running instance of a chart (each install creates one) |
| **Values** | Configuration inputs that fill template placeholders |
| **Templates** | Kubernetes YAML files with variable placeholders |

---

## Helm Chart Structure

```
my-app/
├── Chart.yaml        # Metadata: name, version, description
├── values.yaml       # Default configuration values
└── templates/        # Kubernetes YAML with Go template syntax
    ├── deployment.yaml
    ├── service.yaml
    └── ...
```

### `Chart.yaml`
Defines the chart's name, version, and description. Used for chart versioning and lifecycle management.

### `values.yaml`
Holds all configuration — replicas, image versions, ports, feature flags. Avoids hardcoding in templates.

```yaml
replicaCount: 2
image:
  repository: nginx
  tag: "1.25"
```

### Templates
Normal YAML files with **Go template syntax** for dynamic values:

```yaml
replicas: {{ .Values.replicaCount }}
image: {{ .Values.image.repository }}:{{ .Values.image.tag }}
name: {{ .Release.Name }}
```

---

## Helm Template Syntax

```
{{ .Values.xxx }}      # Access values from values.yaml
{{ .Release.Name }}    # Release name set at install time
{{ if ... }}           # Conditional logic
{{ range ... }}        # Loop over a list
```

---

## Helm Rendering Phase

Before any deployment:
```
Templates + values.yaml → Rendered pure YAML → Applied to cluster
```

You can preview rendered YAML without deploying:
```bash
helm template my-release ./my-app
```

---

## Helm Releases

Each `helm install` creates a **release**:
- Stored inside the cluster
- Tracks version history
- Enables rollback to any previous version

---

## Core Helm Commands

```bash
# Setup
helm version
helm create my-app          # Create a new chart skeleton

# Deploy
helm install my-release ./my-app              # Install chart
helm upgrade my-release ./my-app              # Upgrade release
helm upgrade my-release ./my-app --set replicaCount=3   # Override values

# Inspect
helm list                   # List all releases
helm history my-release     # Show version history

# Rollback
helm rollback my-release 1  # Roll back to revision 1

# Cleanup
helm uninstall my-release   # Remove release
```

---

## Hands-On Lab: Step by Step

### 1. Verify environment
```bash
kubectl get nodes
helm version
kubectl cluster-info
```

### 2. Create a chart
```bash
helm create my-app
# Generates: Chart.yaml, values.yaml, templates/
```

### 3. Edit `values.yaml`
```yaml
replicaCount: 2
image:
  repository: nginx
  tag: "1.25"
```

### 4. Dry-run (preview rendered YAML)
```bash
helm template my-release ./my-app
```

### 5. Install the chart
```bash
helm install my-release ./my-app
```

### 6. Verify deployment
```bash
helm list
kubectl get all
```

### 7. Upgrade (change values)
```bash
helm upgrade my-release ./my-app --set replicaCount=3
```

### 8. View history and rollback
```bash
helm history my-release
helm rollback my-release 1
```

### 9. Cleanup
```bash
helm uninstall my-release
```

---

## When to Use Helm

**Use Helm when:**
- Multiple environments (dev/staging/prod) with different configs
- Reusable services deployed across teams or projects
- Production systems requiring upgrade/rollback capabilities

**Avoid Helm when:**
- Single YAML files
- Learning Kubernetes basics (start with plain YAML first)
- One-off experiments

---

## Key Takeaways

1. Helm packages all a service's YAML into a single reusable chart
2. `values.yaml` eliminates hardcoding — one chart works across environments
3. Each `helm install` creates a tracked **release** with full version history
4. `helm upgrade` applies changes; `helm rollback` reverts to any previous revision
5. Helm renders templates to plain YAML before sending to Kubernetes — K8s never knows Helm exists

---

## Assignment

**Goal:** Create a Helm chart from scratch for `hashicorp/http-echo` (or `busybox`) and manage it with Helm lifecycle commands.

**Required chart structure:**
```
helm-from-scratch/
├── charts/myapp/
│   ├── Chart.yaml
│   ├── values.yaml
│   └── templates/
│       ├── deployment.yaml
│       ├── service.yaml
│       ├── daemonset.yaml
│       ├── cronjob.yaml
│       ├── job.yaml
│       ├── configmap.yaml
│       └── secret.yaml
├── README.md
├── answers.md
└── outputs/
    ├── helm-install.txt
    ├── helm-upgrade.txt
    ├── helm-history.txt
    └── helm-rollback.txt
```

**Tasks:**
1. Write all templates from scratch (AI tools allowed but you must explain each one)
2. Deploy with `helm upgrade --install myapp ./charts/myapp`
3. Upgrade by changing the image tag in `values.yaml`
4. Check `helm history` and rollback to revision 1
5. Mount a ConfigMap and Secret into the Deployment and DaemonSet
6. **Bonus:** Add `bitnami/nginx` external chart; override `image.tag=1.23.0`

---

## Student Answers

**Chart metadata (`Chart.yaml`):**
```yaml
apiVersion: v2
name: myapp
description: Helm chart for hashicorp/http-echo HTTP echo server
version: 1.0.0
appVersion: "0.2.3"
```

**`values.yaml`:**
```yaml
image:
  repository: hashicorp/http-echo
  tag: "0.2.3"
  pullPolicy: IfNotPresent
replicaCount: 1
service:
  type: ClusterIP
  port: 80
  targetPort: 5200
cronJob:
  schedule: "0 * * * *"
```

**Key commands used:**
```bash
# Install
helm upgrade --install myapp-release ./charts/myapp -n dev --create-namespace

# View status and history
helm status myapp-release -n dev
helm history myapp-release -n dev

# Rollback to revision 1
helm rollback myapp-release 1 -n dev

# Dry run
helm upgrade --install myapp-release ./charts/myapp -n dev --dry-run --debug

# Validate
helm lint ./charts/myapp
helm template myapp-release ./charts/myapp -n dev

# External chart
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm upgrade --install external-nginx bitnami/nginx -n dev --set image.tag=1.23.0
```

**Why `helm upgrade --install` is preferred:**
- Idempotent — install if not exists, upgrade if it does
- Avoids "already exists" / "not found" errors in CI/CD pipelines
- Single command for all environments

**ConfigMap & Secret mounting:**
- Configuration (e.g., message text, port) stored in ConfigMap under `configMap.data`
- Sensitive data (API tokens) stored in Secret under `secret.data` (base64 encoded)
- Both mounted via `envFrom` (as env vars) and `volumeMounts` at `/etc/config` and `/etc/secret`
