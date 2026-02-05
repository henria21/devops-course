# Helm from Scratch

This repository contains a complete Helm chart implementation for deploying BusyBox containers with various Kubernetes workload types.

## Chart Structure

```
helm-from-scratch/
├── charts/
│   └── myapp/
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
│           ├── _helpers.tpl
│           ├── deployment.yaml
│           ├── service.yaml
│           ├── daemonset.yaml
│           ├── cronjob.yaml
│           ├── job.yaml
│           ├── configmap.yaml
│           └── secret.yaml
├── README.md
├── answers.md
└── outputs/
    ├── helm-install.txt
    ├── helm-upgrade.txt
    ├── helm-history.txt
    └── helm-rollback.txt
```

## Chart Details

- **Chart Name**: myapp
- **Version**: 1.0.0
- **App Version**: 0.2.3
- **Image**: hashicorp/http-echo:0.2.3

## Features

The chart includes templates for:

1. **Deployment** - Standard Kubernetes Deployment for running BusyBox
2. **Service** - ClusterIP service for exposing the deployment
3. **DaemonSet** - Runs on every node in the cluster
4. **CronJob** - Scheduled execution of BusyBox commands
5. **Job** - One-time batch execution
6. **ConfigMap** - Optional configuration data
7. **Secret** - Optional sensitive data storage

## Default Configuration

The container runs hashicorp/http-echo, which is an HTTP echo server that mirrors HTTP requests back to the client. It runs with the default HTTP server configuration on port 5200.

## Installation

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

## Values Override

You can override values using the `-f` flag or `--set` flag:

```bash
helm install myapp-release ./charts/myapp \
  --set image.tag=1.35 \
  --set replicaCount=3
```

## Optional ConfigMap and Secret

The ConfigMap and Secret templates are optional and not configured by default. To use them, add configuration to your values.yaml file:

```yaml
configMap:
  data:
    KEY1: value1
    KEY2: value2

secret:
  data:
    USERNAME: myuser
    PASSWORD: mypassword
```

## CronJob Schedule

Default schedule runs hourly (0 * * * *). Modify in values.yaml to change the schedule.

## Job Configuration

- backoffLimit: 3 (retries)

## See Also

For detailed Helm commands, outputs, and chart structure documentation, see [answers.md](answers.md).

All Helm command outputs are stored in the `outputs/` directory:

- `helm-install.txt` - Output from helm install command
- `helm-upgrade.txt` - Output from helm upgrade command
- `helm-history.txt` - Output from helm history command
- `helm-rollback.txt` - Output from helm rollback command

## Chart Metadata

**Chart Version**: 1.0.0  
**App Version**: 1.36  
**Image**: busybox:1.36  
**Last Updated**: February 2026
