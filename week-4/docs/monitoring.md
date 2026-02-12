# Monitoring & Observability Setup

## Stack Components
- **Prometheus**: Core metrics engine.
- **Grafana**: Visualization dashboards.
- **kube-prometheus-stack**: Helm chart used for deployment.
- **Prometheus FastApi Instrumentator**: Python library for app metrics.

## Installation
The monitoring stack is installed automatically via `scripts/install-monitoring.sh`:
```bash
bash scripts/install-monitoring.sh
```

## Metrics Collection
- The FastAPI app exposes metrics at `/metrics`.
- A `PodMonitor` in `k8s/monitoring/podmonitor.yaml` tells Prometheus to scrape these pods.
- Metrics are tagged with `app: fastapi-app`.

## Dashboards
- Access Grafana via the LoadBalancer service in the `monitoring` namespace.
- Default credentials: `admin / prom-operator`.
- Recommended dashboards to import:
  - Kubernetes / Compute Resources / Namespace (Pods)
  - FastAPI custom metrics (Request Duration, Error Rate)
