# GIS Demo — Cloud-Native Deployment on GKE

A minimal FastAPI service deployed on Google Kubernetes Engine (GKE) with a full cloud-native DevOps pipeline, demonstrating containerization, infrastructure as code, CI/CD automation, blue-green deployment, API gateway, and cloud monitoring.

## Live Demo

| Endpoint | URL |
|----------|-----|
| API | `http://gis-demo-api.endpoints.gis-demo-498621.cloud.goog` |
| Health Check | `http://gis-demo-api.endpoints.gis-demo-498621.cloud.goog/health` |

## Architecture

```
User Request
     ↓
Cloud Endpoints (API Gateway)
     ↓
GKE LoadBalancer (External IP)
     ↓
Kubernetes Service (selector: blue or green)
     ↓
FastAPI Container (blue or green Deployment)
     ↓
Secret Manager (VERSION config)
```

## Tech Stack

| Layer | Technology |
|-------|------------|
| Application | FastAPI (Python) |
| Containerization | Docker |
| Container Registry | GCP Artifact Registry |
| Orchestration | Google Kubernetes Engine (GKE) |
| Infrastructure as Code | Terraform |
| CI/CD | GitHub Actions |
| API Gateway | Cloud Endpoints |
| Secret Management | GCP Secret Manager |
| Monitoring | Cloud Logging |

## Project Structure

```
gis-demo/
├── main.py                    # FastAPI application
├── Dockerfile                 # Container definition
├── requirements.txt           # Python dependencies
├── k8s-blue.yaml              # Blue deployment manifest
├── k8s-green.yaml             # Green deployment manifest
├── k8s-service.yaml           # Kubernetes Service (traffic control)
├── endpoints.yaml             # Cloud Endpoints API spec
├── terraform/
│   ├── main.tf                # GCP resources definition
│   ├── variables.tf           # Variable declarations
│   ├── outputs.tf             # Output values
│   └── terraform.tfvars       # Variable values (gitignored)
└── .github/
    └── workflows/
        └── deploy.yml         # GitHub Actions CI/CD pipeline
```

## Infrastructure (Terraform)

Three GCP resources provisioned via Terraform:

- **GKE Cluster** (`gis-demo-cluster`) — 2 nodes, e2-medium
- **Artifact Registry** (`gis-demo`) — Private Docker image repository
- **Secret Manager** (`app-version`) — Stores VERSION config securely

## CI/CD Pipeline (GitHub Actions)

Every push to `main` triggers:

1. Authenticate to GCP using Service Account
2. Build Docker image tagged with commit SHA
3. Push image to Artifact Registry
4. Deploy to GKE via `kubectl set image`
5. Verify rollout status

## Blue-Green Deployment

Two identical deployments run simultaneously. Traffic is controlled by the Kubernetes Service selector:

```bash
# Switch traffic to green
kubectl patch service gis-demo-service \
  -p '{"spec":{"selector":{"app":"gis-demo","version":"green"}}}'

# Rollback to blue
kubectl patch service gis-demo-service \
  -p '{"spec":{"selector":{"app":"gis-demo","version":"blue"}}}'
```

Zero downtime — both versions run in parallel, traffic switches instantly. Rollback takes under 30 seconds.

## API Gateway (Cloud Endpoints)

Cloud Endpoints sits in front of the service providing:

- Unified domain name (no direct IP exposure)
- API usage monitoring (request count, latency, error rates)
- Foundation for API key authentication and rate limiting

## Monitoring (Cloud Logging)

Container logs automatically shipped to GCP Cloud Logging. Query in Logs Explorer:

```
resource.type="k8s_container"
resource.labels.cluster_name="gis-demo-cluster"
```

## Security

- No credentials hardcoded in source code
- GCP Secret Manager stores runtime configuration
- GitHub Actions uses Service Account with least-privilege IAM roles
- `terraform.tfvars` excluded from version control via `.gitignore`
- Service Account scoped to `container.developer` and `artifactregistry.writer` only
