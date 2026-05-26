# Lesson 7 — Continuous Integration (GitHub Actions)
> Source: `Continuous Integration.pptx` (17 slides)

---

## What is CI/CD?

| Term | Meaning |
|---|---|
| **CI** — Continuous Integration | Build & test every code change; catch errors early |
| **CD** — Continuous Delivery | Prepare artifacts for deployment — optionally deploy automatically |

---

## Why CI/CD is Critical for Kubernetes

**Without CI/CD:**
- Manual builds
- Manual Docker image tagging
- Manual deployments

**With CI/CD:**
```
git push → build → test → image → deploy
```
Kubernetes + Git = automation by design

---

## Why GitHub Actions?

- **Built into GitHub** — no separate CI server needed
- **YAML-based** — workflow as code
- **Free tier** is sufficient for most projects
- **Huge Marketplace** — thousands of pre-built actions
- Every repository gets CI/CD out of the box

### Minimal workflow example
```yaml
name: Demo
on: push
jobs:
  hello:
    runs-on: ubuntu-latest
    steps:
      - run: echo "Hello CI"
```

---

## GitHub Actions Folder Structure

```
.github/
└── workflows/
    └── ci.yaml
```

> **Rule:** If it's not under `.github/workflows/`, it will **not** run.

---

## Workflow Anatomy

```yaml
name: CI Pipeline           # Workflow name (shown in GitHub UI)
on: [push, pull_request]    # Trigger events

jobs:
  build:                    # Job name
    runs-on: ubuntu-latest  # Runner OS
    steps:
      - uses: actions/checkout@v3          # Step: checkout code
      - uses: actions/setup-python@v4      # Step: setup Python
        with:
          python-version: "3.11"
      - run: pip install -r requirements.txt  # Step: install deps
      - run: pytest                           # Step: run tests
```

### Key concepts
| Concept | Description |
|---|---|
| **Workflow** | Automated process defined in a YAML file |
| **Trigger (`on:`)** | Event that starts the workflow (push, PR, schedule) |
| **Job** | Set of steps running on the same runner |
| **Step** | Individual task — uses a pre-built action or runs a shell command |
| **Runner** | The server (VM) that executes the job |

---

## Checkout Action (Mandatory First Step)

```yaml
- uses: actions/checkout@v3
```

Every pipeline must start with checkout — without it, there is no code to build or test.

---

## GitHub Secrets

Used to securely store sensitive values (Docker credentials, tokens, API keys):
- **Encrypted** — never shown in logs
- **Never printed** — masked automatically in output
- **Injected at runtime** — available as environment variables during the workflow

```yaml
env:
  DOCKER_USERNAME: ${{ secrets.DOCKER_USERNAME }}
  DOCKER_PASSWORD: ${{ secrets.DOCKER_PASSWORD }}
```

---

## Setting Up Python

```yaml
- uses: actions/setup-python@v4
  with:
    python-version: "3.11"

- name: Install dependencies
  run: pip install -r requirements.txt

- name: Run tests
  run: pytest
```

> **Rule:** If tests fail → pipeline **must** fail (no merge without passing tests)

---

## Docker Build & Push

Using the official Marketplace action (better than shell commands — caching, cleaner output):

```yaml
- name: Log in to DockerHub
  uses: docker/login-action@v3
  with:
    username: ${{ secrets.DOCKER_USERNAME }}
    password: ${{ secrets.DOCKER_PASSWORD }}

- name: Build and push
  uses: docker/build-push-action@v5
  with:
    context: .
    push: true
    tags: username/my-app:${{ github.sha }}
```

---

## Full CI Pipeline Example

```yaml
name: CI Pipeline
on: push

jobs:
  build-and-push:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - uses: actions/setup-python@v4
        with:
          python-version: "3.11"

      - name: Install dependencies
        run: pip install -r requirements.txt

      - name: Run tests
        run: pytest

      - name: Build and push Docker image
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: ${{ secrets.DOCKER_USERNAME }}/my-app:${{ github.sha }}
```

---

## GitHub Actions Marketplace

Public registry of pre-built actions:
- Maintained by GitHub, Docker, and the community
- Covers: Docker build, Python setup, Helm, Kubernetes, and thousands more
- Avoids reinventing the wheel

---

## Branch-Based Pipelines

Different branches can trigger different workflows:

```yaml
on:
  push:
    branches:
      - main        # Deploy to production
      - develop     # Deploy to staging
  pull_request:     # Run tests only
```

---

## Typical CI Pipeline Flow

```
Checkout → Setup runtime → Install dependencies → Run tests → Build image → Push image
```

---

## CI + Helm + GitOps Flow (Full Automation)

```
GitHub Actions
  → Build Docker image
  → Push image to registry
  → Update Helm values.yaml with new image tag
  → Commit to Git
  → ArgoCD detects Git change
  → ArgoCD syncs cluster
  → Cluster updated automatically
```

---

## Key Takeaways

1. CI = automatically build and test every code push
2. GitHub Actions is YAML-based, built into GitHub, no extra server needed
3. Always start with `actions/checkout` — no code without it
4. Use **Secrets** for all credentials — never hardcode tokens
5. Use Marketplace actions for Docker, Python, etc. — don't write shell scripts for common tasks
6. **If tests fail → pipeline fails** — this is the whole point of CI

---

## Assignment

**Goal:** Create a working GitHub Actions CI pipeline that tests, builds, and pushes a Docker image.

**Parts:**
1. **Repository Setup (20%)** — Create a GitHub repo with a simple app (Flask/Express), `Dockerfile`, `requirements.txt`, and at least one test
2. **CI Workflow (40%)** — Create `.github/workflows/ci.yaml` that: runs on push, checkouts code, installs deps, runs tests, builds & pushes Docker image using `docker/build-push-action`
3. **Secrets Management (20%)** — Store `DOCKER_USERNAME` and `DOCKER_PASSWORD` in GitHub Secrets; verify they don't print in logs
4. **Best Practices Questions (20%)** — Answer in `README.md`: Why avoid `kubectl apply` in CI? Why is `latest` a bad tag? CI vs CD difference? How does this support GitOps?

**Rules:** Image tag must be the **Git commit SHA** — never `latest`.

**Bonus:** Branch-based tagging (`dev-<sha>` vs `prod-<sha>`); pin action versions (no `@main`).

---

> *No student answers file found in the repo for this lesson.*
