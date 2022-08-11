
https://magmax.org/en/blog/argocd/
#create the kind kubernetes cluster

kind create cluster --config=argo-cluster.yaml

# deploy nginx ingress controller
kubectl apply --filename https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/kind/deploy.yaml

# wait for it to be ready
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s

#install cert manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.9.1/cert-manager.yaml

#verify cert manager installation
kubectl get pods --namespace cert-manager

#deploy self signed certificate issuer
kubectl apply -f certificate-issuer.yaml

#check if cluster issuer is ready for signing
kubectl get clusterissuers -o wide selfsigned-cluster-issuer

#install argo cd
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

#deploy the ingress 
kubectl apply -f ingress.yaml

#open the browser at https://argocd.local/

#get the password
 kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

#install argo cd command line interface
brew install argocd

#login to argocd using CLI
argocd login argocd.local

# create namespace to install application
kubectl create namespace guestbook

#install application
kubectl apply -f guestbook.yaml
