#! /bin/sh

# Minikube update script file
# URL still accurate
minikube delete && \
sudo rm -rf /usr/local/bin/minikube && \
# sudo curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && \
# sudo chmod +x minikube && \
# sudo cp minikube /usr/local/bin/ && \
# sudo rm minikube && \
# based on https://minikube.sigs.k8s.io/docs/start/?arch=%2Flinux%2Fx86-64%2Fstable%2Fbinary+download
curl -LO https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube && rm minikube-linux-amd64
minikube start &&\


# Enabling addons: ingress, dashboard
minikube addons enable ingress && \
minikube addons enable dashboard && \
minikube addons enable metrics-server && \
# Showing enabled addons
echo 'Enabled Addons' && \
minikube addons list | grep STATUS && minikube addons list | grep enabled && \

# Showing current status of Minikube
echo 'Current status of Minikube' && minikube status
