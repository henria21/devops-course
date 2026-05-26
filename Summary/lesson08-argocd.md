# Lesson 8 — Continuous Deployment with ArgoCD (GitOps)
> Source: `Continuous Deployment using ArgoCD.pptx` (18 slides)

---

## What is GitOps?

**Git is the single source of truth** for both infrastructure and applications.

Instead of:
```bash
kubectl apply -f deployment.yaml   # ❌ manual, no audit trail
```

With GitOps:
1. Commit to Git
2. GitOps controller detects change
3. Cluster reconciles automatically

### Core GitOps Principles
| Principle | Description |
|---|---|
| **Declarative** | Desired state is described in code (YAML/Helm) |
| **Version-controlled** | All changes tracked in Git with full history |
| **Automated reconciliation** | Controller continuously syncs cluster to Git state |
| **Fully auditable** | Every change has author, timestamp, commit message |

---

## What is ArgoCD?

ArgoCD is a **Kubernetes-native GitOps controller** that:
- Is installed **inside** the cluster
- Continuously monitors Git repositories
- Automatically syncs Kubernetes resources to match Git

**ArgoCD compares:**
- **Desired state** (Git) vs **Actual state** (Cluster)
- If drift occurs → ArgoCD **fixes it automatically**

### Popular GitOps Tools

| Tool | Notes |
|---|---|
| **ArgoCD** | UI dashboard, strong Helm & Kustomize support, enterprise-friendly |
| **Flux** | CNCF graduated, very Git-native, lightweight, strong automation |

---

## Installing ArgoCD

```bash
kubectl apply -n argocd -f \
  https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

---

## Accessing the ArgoCD UI

```bash
# Port-forward to access locally
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Open browser: https://localhost:8080
# Default user: admin
# Get initial password:
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
```

---

## Full CI → CD Flow

```
Developer pushes code
  ↓
GitHub Actions:
  1. Build Docker image
  2. Tag with git SHA
  3. Push to registry
  4. Update GitOps repo values file (Helm values.yaml)
  ↓
ArgoCD detects Git change (new image tag)
  ↓
ArgoCD syncs the correct namespace automatically
  ↓
Cluster updated — no manual kubectl needed
```

---

## Why This is Real GitOps

| Principle | How it's met |
|---|---|
| **CI builds artifacts** | GitHub Actions builds & pushes Docker image |
| **CD pulls from Git** | ArgoCD watches the Git repo, never polls registry |
| **Git is source of truth** | Helm values.yaml in Git drives what runs in cluster |
| **No kubectl in production** | ArgoCD applies changes — humans only commit to Git |
| **Full audit trail** | Git log = complete deploy history |
| **Drift correction** | ArgoCD detects and fixes any manual cluster changes |

---

## Helm GitOps Repository Structure

```
gitops-repo/
├── apps/
│   ├── dev/
│   │   └── values.yaml      # dev-specific values (image tag, replicas)
│   └── prod/
│       └── values.yaml      # prod-specific values
└── charts/
    └── my-app/              # Shared Helm chart
        ├── Chart.yaml
        ├── values.yaml      # Defaults
        └── templates/
```

---

## Dev / Prod Parity Strategy

**Same across environments:**
- Helm chart (one chart for all)
- CI pipeline
- Container registry

**Different per environment:**
| | Dev | Prod |
|---|---|---|
| Git branch | `develop` | `main` / `master` |
| K8s namespace | `dev` | `prod` |
| values.yaml | `values-dev.yaml` | `values-prod.yaml` |
| Image tag | Latest SHA | Pinned SHA |

---

## ArgoCD Application (Dev Example)

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-app-dev
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/org/gitops-repo
    targetRevision: develop
    path: apps/dev
    helm:
      valueFiles:
        - values-dev.yaml
  destination:
    server: https://kubernetes.default.svc
    namespace: dev
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

---

## GitHub Actions: Build, Push, Update GitOps

```yaml
# Step 1: Build & Push Docker image
- name: Build and push
  uses: docker/build-push-action@v5
  with:
    push: true
    tags: username/my-app:${{ github.sha }}

# Step 2: Update GitOps repo with new image tag
- name: Update image tag in GitOps repo
  run: |
    git clone https://github.com/org/gitops-repo
    cd gitops-repo
    sed -i "s/tag:.*/tag: ${{ github.sha }}/" apps/dev/values-dev.yaml
    git add . && git commit -m "ci: update image to ${{ github.sha }}"
    git push
```

---

## Key Takeaways

1. **GitOps** = Git is the single source of truth; cluster always matches what's in Git
2. **ArgoCD** continuously watches Git and auto-syncs the cluster — no manual kubectl
3. CI (GitHub Actions) builds images; CD (ArgoCD) deploys them — clear separation
4. Drift correction: if someone manually changes the cluster, ArgoCD reverts it
5. Dev/prod parity: same Helm chart, different branches and `values.yaml`
6. Every deployment is a Git commit — full audit trail, rollback by reverting a commit

---

## Assignment

**Goal:** Deploy ArgoCD into Minikube and implement a full GitOps workflow with dev/prod environments using Helm.

**Parts:**
1. Start Minikube (`--cpus=4 --memory=8192`); enable ingress addon
2. Install ArgoCD in `argocd` namespace; wait for all pods to be ready
3. Access ArgoCD UI via port-forward; retrieve initial admin password
4. Create GitHub repo `helm-gitops-demo` with Helm chart structure; create `dev` and `main` branches with different `values-dev.yaml` (1 replica) and `values-prod.yaml` (3 replicas)
5. Deploy dev Application (`myapp-dev`) pointing to `dev` branch; deploy prod (`myapp-prod`) pointing to `main` branch; both with `syncPolicy: automated`
6. **GitOps reconciliation demo** — change `replicaCount: 2` in `values-dev.yaml`, push to `dev` branch, observe ArgoCD automatically updates the cluster

**Final deliverables:** GitHub repo link + screenshots of ArgoCD UI showing both apps + explanation of how reconciliation works.

**Bonus:** Use commit SHA instead of branch; add ArgoCD Project; add RBAC; use Image Updater.

---

> *No student answers file found in the repo for this lesson.*
