# GitOps with ArgoCD

A complete GitOps implementation using ArgoCD for Kubernetes cluster management. This project demonstrates automatic synchronization, health checks, drift detection, and multi-environment promotions.

## 🎯 Features

- ✅ **GitOps Workflow** - All cluster state managed through Git
- ✅ **Automatic Synchronization** - Changes in Git automatically applied to cluster
- ✅ **Health Checks** - Readiness and liveness probes for application health
- ✅ **Drift Detection** - Automatic detection of manual cluster changes
- ✅ **Self-Healing** - Automatic revert of unauthorized changes
- ✅ **Multi-Environment** - Staging and Production environments with directory-based separation

## 📁 Project Structure

```
gitops-argocd/
├── README.md                    # This file
├── SETUP.md                     # Setup and deployment guide
├── argocd/                      # ArgoCD configurations
│   ├── project.yaml             # ArgoCD Project definition
│   └── applications/
│       ├── staging-app.yaml     # Staging environment Application
│       └── production-app.yaml  # Production environment Application
├── namespaces/                  # Kubernetes namespace definitions
│   ├── staging-namespace.yaml
│   └── production-namespace.yaml
└── apps/                        # Application manifests
    └── my-app/
        ├── staging/             # Staging environment manifests
        │   ├── deployment.yaml
        │   ├── service.yaml
        │   └── configmap.yaml
        └── production/          # Production environment manifests
            ├── deployment.yaml
            ├── service.yaml
            └── configmap.yaml
```

## 🚀 Quick Start

1. **Install ArgoCD** on your Kubernetes cluster
2. **Update repository URL** in `argocd/applications/*.yaml`
3. **Apply configurations**:
   ```bash
   kubectl apply -f namespaces/
   kubectl apply -f argocd/project.yaml
   kubectl apply -f argocd/applications/
   ```

For detailed instructions, see [SETUP.md](./SETUP.md).

## 🔄 GitOps Workflow

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Developer  │────▶│     Git     │────▶│   ArgoCD    │
│   Commits   │     │ Repository  │     │  Monitors   │
└─────────────┘     └─────────────┘     └──────┬──────┘
                                               │
                           ┌───────────────────┴───────────────────┐
                           ▼                                       ▼
                    ┌─────────────┐                         ┌─────────────┐
                    │   Staging   │                         │ Production  │
                    │   Cluster   │                         │   Cluster   │
                    └─────────────┘                         └─────────────┘
```

## 🌍 Multi-Environment Promotion

This project uses the **directory-based approach** for environment management:

| Environment | Path | Replicas | Description |
|------------|------|----------|-------------|
| Staging | `apps/my-app/staging/` | 2 | Testing environment |
| Production | `apps/my-app/production/` | 3 | Live environment |

### Promotion Process

1. Make and test changes in staging
2. Copy manifests from `staging/` to `production/`
3. Commit and push to Git
4. ArgoCD automatically syncs production

## ⚙️ Key Configurations

### Automatic Sync (syncPolicy.automated)
```yaml
syncPolicy:
  automated:
    prune: true      # Remove resources not in Git
    selfHeal: true   # Revert manual changes
```

### Health Checks (Probes)
```yaml
readinessProbe:
  httpGet:
    path: /
    port: 80
livenessProbe:
  httpGet:
    path: /
    port: 80
```

## 📊 Monitoring

### Check Application Status
```bash
kubectl get applications -n argocd
argocd app get my-app-staging
```

### View Sync Status
- **Synced**: Cluster matches Git
- **OutOfSync**: Drift detected
- **Healthy**: Application running correctly
- **Degraded**: Health check failures

## 🔧 Testing Features

### Test Drift Detection
```bash
# Make manual change
kubectl scale deployment my-app -n staging --replicas=5

# ArgoCD will detect and show OutOfSync
# With selfHeal, it reverts automatically
```

### Test Automatic Sync
```bash
# Edit deployment.yaml, commit, push
# ArgoCD detects change and applies within 3 minutes
```

## 📝 License

MIT License
