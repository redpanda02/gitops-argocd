# GitOps with ArgoCD - Setup and Deployment Guide

This script helps you set up and deploy the GitOps project with ArgoCD.

## Prerequisites

Before running these commands, ensure you have:

1. **Kubernetes Cluster** (minikube, kind, Docker Desktop, or cloud-based)
2. **kubectl** configured to connect to your cluster
3. **ArgoCD CLI** (optional but recommended)

---

## Step 1: Install ArgoCD

```bash
# Create ArgoCD namespace
kubectl create namespace argocd

# Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD to be ready
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd
```

---

## Step 2: Access ArgoCD UI

```bash
# Option 1: Port forward (for local access)
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Option 2: Expose via LoadBalancer (for cloud clusters)
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
```

**Get Initial Admin Password:**
```bash
# For ArgoCD v2.x+
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Login with: admin / <password from above>
```

---

## Step 3: Configure Repository (Required)

Before deploying, update the repository URL in the Application manifests:

1. Edit `argocd/applications/staging-app.yaml`
2. Edit `argocd/applications/production-app.yaml`
3. Replace `https://github.com/YOUR_USERNAME/gitops-argocd.git` with your actual repository URL

**If using a private repository:**
```bash
# Add repository credentials
argocd repo add https://github.com/YOUR_USERNAME/gitops-argocd.git \
  --username YOUR_USERNAME \
  --password YOUR_PAT_TOKEN
```

---

## Step 4: Deploy ArgoCD Resources

```bash
# Create namespaces first
kubectl apply -f namespaces/

# Apply ArgoCD Project
kubectl apply -f argocd/project.yaml

# Apply Applications
kubectl apply -f argocd/applications/
```

---

## Step 5: Verify Deployment

```bash
# Check application status
kubectl get applications -n argocd

# Check pods in staging
kubectl get pods -n staging

# Check pods in production
kubectl get pods -n production

# Using ArgoCD CLI
argocd app list
argocd app get my-app-staging
argocd app get my-app-production
```

---

## Step 6: Test GitOps Features

### Test Automatic Sync
```bash
# Make a change to staging deployment (e.g., change replicas)
# Commit and push to Git
# ArgoCD will automatically detect and apply changes
```

### Test Drift Detection
```bash
# Manually scale deployment
kubectl scale deployment my-app -n staging --replicas=5

# ArgoCD will detect drift and show OutOfSync status
# With selfHeal enabled, it will automatically revert to Git state
```

### View Sync Status
```bash
argocd app get my-app-staging
argocd app get my-app-production
```

---

## Useful ArgoCD CLI Commands

```bash
# Login to ArgoCD
argocd login localhost:8080

# List all applications
argocd app list

# Get application details
argocd app get my-app-staging

# Manually sync an application
argocd app sync my-app-staging

# View application history
argocd app history my-app-staging

# Rollback to previous version
argocd app rollback my-app-staging <REVISION>

# Delete an application
argocd app delete my-app-staging
```

---

## Multi-Environment Promotion Workflow

### From Staging to Production:

1. **Test in Staging**: Deploy and test changes in staging environment
2. **Copy Manifests**: Copy updated manifests from `apps/my-app/staging/` to `apps/my-app/production/`
3. **Commit & Push**: Commit changes and push to Git
4. **ArgoCD Syncs**: ArgoCD automatically detects and applies changes to production

```bash
# Example: Copy staging deployment to production
cp apps/my-app/staging/deployment.yaml apps/my-app/production/
git add .
git commit -m "Promote staging to production"
git push
```
