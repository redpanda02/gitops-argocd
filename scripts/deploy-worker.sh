#!/bin/bash
# =============================================================================
# GitOps ArgoCD Deployment Script - Worker Node (Server 2.1)
# Run this on: 137.184.47.129
# =============================================================================

set -e

echo "=========================================="
echo "  GitOps ArgoCD - Worker Node Setup"
echo "=========================================="

# Variables - UPDATE THESE!
MASTER_IP="137.184.45.113"
K3S_TOKEN="PASTE_TOKEN_FROM_MASTER_HERE"  # Get from master: cat /var/lib/rancher/k3s/server/node-token

# Step 1: Update system
echo "[1/2] Updating system packages..."
apt-get update && apt-get upgrade -y

# Step 2: Install K3s (Worker Node)
echo "[2/2] Installing K3s worker node..."
curl -sfL https://get.k3s.io | K3S_URL=https://$MASTER_IP:6443 K3S_TOKEN=$K3S_TOKEN sh -

echo ""
echo "=========================================="
echo "  WORKER NODE SETUP COMPLETE!"
echo "=========================================="
echo ""
echo "Verify on master node with: kubectl get nodes"
echo ""
