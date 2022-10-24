# Setup TLS

We're going to setup TLS for services running in your k8s cluster using cert-manager and we'll create the certs via mkcert

## Pre-reqs

* Helm
* choco: https://chocolatey.org/
* mkcert, install via: `choco install mkcert` 

## Install cert-manager

1. add the helm repo where cert-manager is maintained at (and update your local helm cache): `helm repo add jetstack https://charts.jetstack.io && helm repo update`
2. Install cert-manager:
   
```
helm install `
  cert-manager jetstack/cert-manager `
  --namespace cert-manager `
  --create-namespace `
  --version v1.9.1 `
  --set installCRDs=true
```

## Create a new local CA cert

1. Set your env var for mkcert script, `$ENVIRONMENT="DEV"`
2. Run `./create-cert.ps1`

CA private key and a public certificate should have been created in the dev folder.

> :warning: the rootCA-key.pem file that mkcert automatically generates gives complete power to intercept secure requests from your machine. Do not share it.

## Create a secret in k8s

Creating K8S secrets with the CA private keys (will be used by the cert-manager CA Issuer)



```
kubectl -n kavm-services create secret tls mkcert-ca-tls-secret --key="${CA_CERTS_FOLDER}/${ENVIRONMENT}/rootCA-key.pem" --cert="${CA_CERTS_FOLDER}/${ENVIRONMENT}/rootCA.pem"
```

## Create an Issuer

We're going to create a Issuer resource that will be used for a specific namespace. To get more detail on this resource, run `k explain Issuer`

`k apply -f .\issuer.yaml`


## Create a cert-manager Certificate

`k apply -f .\certificate.yaml`

## Enable TLS in ingress for the api and ui sample apps

- Add a tls block to enable https in  `apps\base\kavm-services\ref-net-core-api\ingress.yaml` and `apps\base\kavm-services\ref-ng-ui\ingress.yaml` (it's currently commented out, uncomment the tls sections and the host under `rules`)
- push changes and let flux reconcile
- try out the ui and api now on https protocol!



### Alternate ways to install cert-manager

Output YAML
Instead of directly installing cert-manager using Helm, a static YAML manifest can be created using the Helm template command. This static manifest can be tuned by providing the flags to overwrite the default Helm values:

```
helm template \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.9.1 \
  # --set prometheus.enabled=false \   # Example: disabling prometheus using a Helm parameter
  # --set installCRDs=true \           # Uncomment to also template CRDs
  > cert-manager.custom.yaml
```


### Troubleshooting

- To look at how ingress is setup: ` k get ing -n kavm-services`
