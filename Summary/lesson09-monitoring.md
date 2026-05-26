# Lesson 9 — Monitoring, Alerting & Logging
> Source: `Monitoring.pptx` (16 slides) — *Prometheus Stack*

---

## Why Observability Matters

Distributed systems are complex — pods, nodes, and services are dynamic.

**Without observability:**
- Cannot debug fast when things break
- SLA violations go unnoticed
- Scaling decisions are blind

**Observability = Metrics + Logs + Alerts**

---

## Core Components of the Observability Stack

| Component | Role |
|---|---|
| **Prometheus** | Metrics collection & time-series database |
| **Grafana** | Dashboard builder and visualization |
| **Alertmanager** | Routes alert notifications (Slack, email, PagerDuty) |
| **Loki** | Log aggregation (Grafana-native, lightweight) |
| **Fluent Bit / Fluentd** | Log collection and forwarding agents |
| **Elasticsearch + Kibana** | Alternative log stack (heavier) |

---

## Prometheus

### Overview
- Open-source time-series database
- **Pull model** — scrapes `/metrics` endpoints from targets
- Stores metrics per label (key/value pairs)
- Query language: **PromQL**
- Kubernetes-native service discovery

### Architecture
```
Prometheus Server
  ├── Pulls metrics from /metrics endpoints
  ├── Node Exporter (host-level CPU, memory, disk metrics)
  ├── Kube State Metrics (K8s object metrics — pods, deployments)
  ├── Alertmanager (receives alerts from Prometheus rules)
  └── Persistent Volume (for TSDB storage)
```

Targets are discovered via:
- `ServiceMonitor` (monitors a Kubernetes Service)
- `PodMonitor` (monitors individual Pods directly)

---

## Grafana

### Overview
- Dashboard builder — visualize any data source
- **Data source agnostic**: Prometheus, Loki, Elasticsearch, and more
- Supports variables, templating, and drill-down dashboards
- Pre-built Kubernetes dashboards available from the community
- Built-in alerting with notification channels

### Capabilities
- Query Prometheus with PromQL
- Query Loki for logs
- Correlate metrics and logs on the same dashboard
- Set up alert rules and route to notification channels

---

## Alertmanager

Prometheus evaluates **alerting rules** → sends fired alerts to Alertmanager.

### Alertmanager routes alerts to:
- **Slack** — channel notifications
- **Email** — direct email alerts
- **PagerDuty / Opsgenie** — on-call escalation

### Features
- **Grouping** — combine similar alerts into one notification
- **Silencing** — mute alerts during maintenance windows
- **Deduplication** — avoid repeated notifications for the same issue

---

## Loki + Grafana (Logging)

### Loki
- Stores logs in **label-indexed chunks** (lightweight — no full-text indexing)
- Designed to work alongside Prometheus — uses the **same labels**
- Correlate metrics and logs on the same Grafana dashboard

### Fluent Bit
- Lightweight log collection agent (runs as DaemonSet on every node)
- Forwards logs from pods/nodes to Loki

```
Pod logs → Fluent Bit (DaemonSet) → Loki → Grafana
```

---

## Deploying the Monitoring Stack (Helm)

### Create namespace
```bash
kubectl create namespace monitoring
```

### Add Helm repos
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```

### Deploy Prometheus + Grafana
```bash
helm upgrade --install monitoring \
  prometheus-community/kube-prometheus-stack \
  -n monitoring \
  -f values.yaml
```

### Deploy Loki + Fluent Bit
```bash
helm upgrade --install loki \
  grafana/loki-stack \
  -n monitoring \
  -f loki-values.yaml
```

---

## Accessing Dashboards

```bash
# Grafana (default port 3000)
kubectl port-forward svc/monitoring-grafana -n monitoring 3000:80

# Prometheus (default port 9090)
kubectl port-forward svc/monitoring-kube-prometheus-prometheus -n monitoring 9090:9090

# Loki (default port 3100)
kubectl port-forward svc/loki -n monitoring 3100:3100
```

Open browser:
- Grafana: http://localhost:3000
- Prometheus: http://localhost:9090

---

## Dev / Prod Parity for Monitoring

| Aspect | Dev | Prod |
|---|---|---|
| Namespace | `monitoring-dev` | `monitoring` |
| Helm values | Lower resource limits, short retention | Higher replicas, longer retention |
| Deployment | Declarative via GitOps (ArgoCD) | Same |

> Same stack, different `values.yaml` — same Helm chart for all environments.

---

## Key Takeaways

1. **Observability = Metrics (Prometheus) + Dashboards (Grafana) + Alerts (Alertmanager) + Logs (Loki)**
2. Prometheus uses a **pull model** — it scrapes `/metrics` endpoints
3. Grafana is data-source agnostic — query Prometheus and Loki from the same dashboard
4. Alertmanager routes alerts to Slack, email, PagerDuty — supports grouping and silencing
5. Loki + Fluent Bit for logs: lightweight, uses same labels as Prometheus for correlation
6. Deploy the whole stack with `kube-prometheus-stack` Helm chart
7. Use separate namespaces and `values.yaml` files for dev vs prod

---

## Assignment

**Goal:** Deploy a full observability stack (Prometheus, Grafana, Loki) on Minikube with dev/prod parity.

**Steps:**
1. `minikube start`; create namespaces `monitoring-dev` and `monitoring-prod`
2. Add Helm repos: `prometheus-community` and `grafana`
3. Create `values-dev.yaml` (7-day retention, devadmin password) and `values-prod.yaml` (30-day retention)
4. Deploy Prometheus + Grafana: `helm upgrade --install monitoring-dev prometheus-community/kube-prometheus-stack -n monitoring-dev -f values-dev.yaml`
5. Deploy Loki + Fluent Bit for centralized logging
6. Port-forward dashboards: Grafana `:3000`, Prometheus `:9090`, Loki `:3100`
7. Explore prebuilt dashboards; create a CPU/memory dashboard; query Loki logs
8. *(Optional)* Configure Prometheus alert rule for high CPU; check in Alertmanager UI
9. *(Bonus)* Store Helm values in GitHub and use ArgoCD for automatic GitOps sync

**Deliverables:** GitHub repo with values files + screenshots of dashboards + explanation of `helm upgrade --install`, how alerts work, dev vs prod differences.

---

## Student Answers

**Why `helm upgrade --install` is used:**
- Idempotent — installs if release doesn't exist; upgrades if it does
- Prevents "already exists" / "not found" errors in CI/CD
- Ensures the release always reaches the desired state

**How alerts are configured:**
1. Define Prometheus alerting rules using PromQL threshold conditions
2. Rules continuously evaluate metrics in the cluster
3. When triggered, alert is sent to Alertmanager which handles:
   - **Grouping** — combines similar alerts into one notification
   - **Inhibition** — suppresses lower-priority alerts if a critical one is active
   - **Routing** — sends notifications to Slack, PagerDuty, or email

**Dev vs Prod differences:**

| Aspect | Dev | Prod |
|---|---|---|
| `replicaCount` | 1 replica | Multiple replicas + HPA |
| Resource limits | Low `requests`, minimal `limits` | Strict `limits`, higher `requests` |
| Availability | Single zone | Multi-AZ + Pod Disruption Budgets |
| Security | Permissive NetworkPolicies | Strict NetworkPolicies, encrypted Secrets |
| Retention | 7 days | 30 days |
