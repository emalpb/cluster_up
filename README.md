# cluster_up


kind create cluster --name kind-prueba-end

install istioctl
istioctl install --set profile=default -y

helm repo add argo https://argoproj.github.io/argo-helm\nhelm repo update\nhelm install argocd argo/argo-cd -n argocd --create-namespace
kubectl apply -f argocd/argocd.yaml

kubectl label namespace onlineboutique istio-injection=enabled --overwrite
kubectl label namespace default istio-injection=enabled --overwrite
kubectl label namespace sample-app-istio istio-injection=enabled --overwrite