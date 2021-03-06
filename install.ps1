
helm init --upgrade --service-account tiller

helm del --purge fabricrealtime

Start-Sleep -Seconds 10

$namespace = "fabricrealtime"

if ([string]::IsNullOrWhiteSpace($(kubectl get namespace $namespace --ignore-not-found=true))) {
    Write-Information -MessageData "namespace $namespace does not exist so creating it"
    kubectl create namespace $namespace
}
kubectl delete --all 'deployments,pods,services,ingress,persistentvolumeclaims,jobs,cronjobs' --namespace=$namespace --ignore-not-found=true

Start-Sleep -Seconds 10

# can't delete persistent volume claims since they are not scoped to namespace
kubectl delete 'pv' -l namespace=$namespace --ignore-not-found=true

Start-Sleep -Seconds 10

# Write-Host "First trying a dry-run"

# helm install ./fabricrealtime --name fabricrealtime --dry-run --namespace kube-system --set key1=val1,key2=val2 --debug

# https://docs.helm.sh/using_helm/
Write-Host "Now installing for real"
helm install ./fabricrealtime --name fabricrealtime --namespace kube-system `
        --set onprem=true `
        --debug

Write-Host "Listing packages"
helm list

kubectl get "deployments,pods,services,ingress,secrets" --namespace=$namespace -o wide
