#!/bin/bash

minikube start --driver=docker --cni=cilium

# Wait for Minikube to be up and running
echo "Waiting for Minikube to be up and running..."
while ! minikube status | grep -q "host: Running"; do
  echo "Minikube is not yet running. Waiting..."
  sleep 5
done

echo "Minikube is running!"

# See ./installation/README.md for more details on the installation process

# Run step 1 to check that you have the right permissions to create objects in the cluster
sh /workspaces/installation/preCheck.sh
# Step 2: Helm is added to this devcontainer using features so no need to install it again
minikube tunnel # so that istio gateway can get a public IP
# Step 3: Install Istio using Helm, see details in ./installation/README.md
echo "Installing Istio using Helm..."
# Step 4: Install hashicorp vault using Helm, see details in ./installation/CanvasVault
# run the setup script to install and configure HashiCorp Vault

helm repo add oda-canvas https://tmforum-oda.github.io/oda-canvas
helm repo update

helm install canvas oda-canvas/canvas-oda -n canvas --create-namespace --set=canvas-vault.enabled=false

# find all helm charts used in oda-canvas/canvas-oda
echo "Installing ODA Canvas using Helm..."

# the secret for the hasicorp vault root token is some how not create by the helm chart
# so we create it manually
kubectl create secret generic canvas-vault-hc-secrets --from-literal=rootToken=egalegal --namespace canvas