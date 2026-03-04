# Kubernetes Deployment & Monitoring Explanation

### Why `helm upgrade --install` is used

This command is the standard for automation because it combines two actions into one idempotent operation:

- **Idempotency:** It ensures the release reaches the desired state regardless of whether it's already there.
- **Install Logic:** If the release does not exist in the namespace, Helm performs a fresh install.
- **Upgrade Logic:** If the release exists, Helm calculates the delta between the current state and the new chart/values and applies an upgrade.
- **Pipeline Stability:** It prevents "already exists" or "not found" errors in CI/CD pipelines.

### How alerts are configured

In a typical Prometheus-based stack, alerting follows a structured flow:

1. **Prometheus:** You define specific threshold conditions using PromQL (e.g., `rate(http_requests_total{status="5xx"}[5m]) > 0.05`).
2. **Alerting Rules:** These rules live in your cluster and constantly evaluate the metrics.
3. **Alertmanager:** When a rule triggers, it sends the alert to Alertmanager, which handles:
   - **Grouping:** Combining similar alerts into one notification.
   - **Inhibition:** Suppressing certain alerts if others are already active.
   - **Routing:** Sending the final notification to receivers like Slack, PagerDuty, or Email.

### Differences between Dev & Prod

While the code is identical, the environment configurations differ to balance cost vs. reliability:

- **Resources & Scaling:**
  - **Prod:** Higher `replicaCount`, enabled HPA (Horizontal Pod Autoscaling), and strict resource `limits`.
  - **Dev:** Minimal replicas and lower resource `requests` to save cloud costs.
- **Availability:**
  - **Prod:** Deployed across multiple Availability Zones (AZs) with Pod Disruption Budgets (PDBs).
  - **Dev:** Usually limited to a single zone or smaller node pools.
- **Security:**
  - **Prod:** Strict NetworkPolicies, encrypted Secrets (e.g., via External Secrets or Vault), and restricted RBAC.
  - **Dev:** More permissive for faster debugging and testing.
