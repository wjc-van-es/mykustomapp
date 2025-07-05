#! /bin/sh

kubectl version

##  Step1: Run the below command to download the latest version of kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

## Step2: validate
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"

echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check

##  Step3: Make kubectl executable
chmod +x kubectl

##  Step4: Move it to the directory where kubectl is already installed
sudo mv kubectl $(which kubectl)

kubectl version