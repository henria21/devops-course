# Helm Commands and Outputs

This document contains answers to common Helm operations and their outputs.

## Part 1: Create Helm Chart ✓

### Chart Created Successfully

The Helm chart has been created with the following structure:

```
charts/myapp/
├── Chart.yaml                  # Chart metadata
├── values.yaml                 # Default values
└── templates/
    ├── _helpers.tpl            # Template helpers
    ├── deployment.yaml         # Kubernetes Deployment
    ├── service.yaml            # Kubernetes Service
    ├── daemonset.yaml          # Kubernetes DaemonSet
    ├── cronjob.yaml            # Kubernetes CronJob
    ├── job.yaml                # Kubernetes Job
    ├── configmap.yaml          # Kubernetes ConfigMap (optional)
    └── secret.yaml             # Kubernetes Secret (optional)
```

### Chart.yaml Content

```yaml
apiVersion: v2
name: myapp
description: A Helm chart for running hashicorp/http-echo HTTP echo server
type: application
version: 1.0.0
appVersion: "0.2.3"
author: Helm Developer
maintainers:
  - name: Helm Developer
    email: developer@example.com
```

### values.yaml Content

```yaml
image:
  repository: hashicorp/http-echo
  tag: "0.2.3"
  pullPolicy: IfNotPresent
  command: []

replicaCount: 1

service:
  type: ClusterIP
  port: 80
  targetPort: 5200

cronJob:
  schedule: "0 * * * *"

job:
  backoffLimit: 3
```

## Part 2: Template Files

### 1. Deployment Template
- **File**: `templates/deployment.yaml`
- **Purpose**: Manages stateless application replicas with rolling updates and automatic scaling to ensure high availability
- **In This Chart**: Runs the hashicorp/http-echo container with configurable replicas (currently set to 1)

### 2. Service Template
- **File**: `templates/service.yaml`
- **Purpose**: Creates a stable network endpoint and load balances traffic across pod replicas for reliable service discovery
- **Type**: ClusterIP (internal cluster access)
- **Port Mapping**: 80 -> 5200
- **In This Chart**: Exposes the hashicorp/http-echo HTTP echo server internally on port 80, routing to container port 5200

### 3. DaemonSet Template
- **File**: `templates/daemonset.yaml`
- **Purpose**: Ensures exactly one pod runs on each node in the cluster for system-level tasks like monitoring, logging, or node maintenance
- **In This Chart**: Would run hashicorp/http-echo pod on every cluster node (useful for distributed testing scenarios)

### 4. CronJob Template
- **File**: `templates/cronjob.yaml`
- **Purpose**: Schedules jobs to run at specific times using cron expressions for periodic batch processing and maintenance tasks
- **Default Schedule**: Hourly (0 * * * *)
- **In This Chart**: Runs the hashicorp/http-echo job hourly at minute 0 (0 * * * * = every hour at :00)

### 5. Job Template
- **File**: `templates/job.yaml`
- **Purpose**: Runs a task to completion (one-time execution) with automatic retry capability for batch processing and data loading
- **Backoff Limit**: 3 retries
- **In This Chart**: Runs hashicorp/http-echo once with up to 3 automatic retry attempts if it fails

### 6. ConfigMap Template
- **File**: `templates/configmap.yaml`
- **Purpose**: Stores non-sensitive configuration data (key-value pairs, config files) that can be updated without rebuilding container images
- **In This Chart**: Optional storage for http-echo configuration settings (currently not actively used)

### 7. Secret Template
- **File**: `templates/secret.yaml`
- **Purpose**: Stores sensitive data like passwords, API keys, and credentials in base64-encoded format for secure configuration management
- **In This Chart**: Optional storage for sensitive http-echo configuration or credentials (currently not actively used)

### 8. Helper Templates
- **File**: `templates/_helpers.tpl`
- **Purpose**: Reusable template functions
- **Includes**:
  - `myapp.name`: Chart name
  - `myapp.fullname`: Full release name
  - `myapp.chart`: Chart name and version
  - `myapp.labels`: Common labels
  - `myapp.selectorLabels`: Selector labels

## Helm Commands Reference

### Install or Upgrade Release
```bash
helm upgrade --install myapp-release ./charts/myapp -n dev --create-namespace
```

### View Release Status
```bash
helm status myapp-release -n dev
```

### View Release History
```bash
helm history myapp-release -n dev
```

### Rollback to Previous Release
```bash
helm rollback myapp-release 1 -n dev
```

### Uninstall Release
```bash
helm uninstall myapp-release -n dev
```

### Dry Run Install
```bash
helm upgrade --install myapp-release ./charts/myapp -n dev --create-namespace --dry-run --debug
```

### Validate Chart
```bash
helm lint ./charts/myapp
```

### Template Rendering
```bash
helm template myapp-release ./charts/myapp -n dev
```

## Output Locations

All Helm command outputs are stored in the `outputs/` directory:

- `helm-install.txt` - Output from helm install command
- `helm-upgrade.txt` - Output from helm upgrade command
- `helm-history.txt` - Output from helm history command
- `helm-rollback.txt` - Output from helm rollback command

## Notes

1. **Image**: Uses hashicorp/http-echo 0.2.3
2. **Container**: Runs an HTTP echo server on port 5200 that mirrors HTTP requests back to clients
3. **Minimal Configuration**: Chart is simplified with only essential configuration
4. **Labels**: All resources include proper Helm labels for tracking

---

**Chart Version**: 1.0.0  
**App Version**: 0.2.3  
**Last Updated**: February 2026
