#!/bin/bash
# =============================================================================
# GitOps ArgoCD Deployment Script - Master Node (Server 2.0)
# Run this on: 137.184.45.113
# =============================================================================

set -e

echo "=========================================="
echo "  GitOps ArgoCD - Master Node Setup"
echo "=========================================="

# Variables
WORKER_IP="137.184.47.129"
GITHUB_REPO="https://github.com/redpanda02/gitops-argocd.git"

# Step 1: Update system
echo "[1/7] Updating system packages..."
apt-get update && apt-get upgrade -y

# Step 2: Install K3s (Master Node)
echo "[2/7] Installing K3s master node..."
curl -sfL https://get.k3s.io | sh -s - server \
  --write-kubeconfig-mode 644 \
  --tls-san $(hostname -I | awk '{print $1}')

# Wait for K3s to be ready
echo "Waiting for K3s to be ready..."
sleep 30
kubectl wait --for=condition=Ready nodes --all --timeout=120s

# Step 3: Get node token for worker
echo "[3/7] Saving node token for worker node..."
NODE_TOKEN=$(cat /var/lib/rancher/k3s/server/node-token)
echo "Node token saved. Use this on worker node:"
echo "K3S_TOKEN=$NODE_TOKEN"
echo ""

# Step 4: Create namespaces
echo "[4/7] Creating namespaces..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace staging --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace production --dry-run=client -o yaml | kubectl apply -f -

# Step 5: Install ArgoCD
echo "[5/7] Installing ArgoCD..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD to be ready
echo "Waiting for ArgoCD to be ready..."
sleep 60
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

# Step 6: Expose ArgoCD (NodePort for external access)
echo "[6/7] Exposing ArgoCD server..."
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort", "ports": [{"port": 443, "nodePort": 30443, "name": "https"}]}}'

# Step 7: Clone and apply GitOps configurations
echo "[7/7] Cloning GitOps repository and applying configurations..."
cd /root
rm -rf gitops-argocd
git clone $GITHUB_REPO
cd gitops-argocd

# Apply ArgoCD Project
kubectl apply -f argocd/project.yaml

# Apply ArgoCD Applications
kubectl apply -f argocd/applications/

echo ""
echo "=========================================="
echo "  SETUP COMPLETE!"
echo "=========================================="
echo ""
echo "ArgoCD UI: https://$(hostname -I | awk '{print $1}'):30443"
echo ""
echo "Get admin password with:"
echo "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d && echo"
echo ""
echo "To add worker node, run on Server 2.1 (137.184.47.129):"
echo "curl -sfL https://get.k3s.io | K3S_URL=https://$(hostname -I | awk '{print $1}'):6443 K3S_TOKEN=$NODE_TOKEN sh -"
echo ""
