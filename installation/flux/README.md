# Flux Installation

[Flux](https://toolkit.fluxcd.io/) is a GitOps based deployment service. Sits in Kubernetes and watches source code repositories and artifact repositories. When a change is detected the deployment is pulled and updated.

## Prerequisites

1. You need `Kustomize` installed (see: https://kubectl.docs.kubernetes.io/installation/kustomize/chocolatey/)
   
    ```choco install kustomize```
    > to install a specific version of kustomize:
    > `choco install kustomize --version=3.9.3`
    > to list:  `choco list --by-id-only Kustomize -a`
2. You need to fork this repo for local development, you should not be running this from the core kavmrepository from github.
3. Download Lens to be able to easily view k8s via a gui. This tool helps to get into logs and jump around quickly if you're not familiar with kubectl commands. https://k8slens.dev/

## Installation

> NB: For the install instructions below to work it's important that you're running the below from the main branch of your forked repository, as this is the branch we configure flux to look at to make config changes. If you don't run this from main you will need to merge to main before doing the bootstrap step (step 11).

1. Download the latest flux release zip file for windows_amd64 here: https://github.com/fluxcd/flux2/releases
2. Unzip the file to a folder where you want to store exe files that powershell can run, e.g. `C:\Users\<you>\bin`
3. Add this folder path to your env path in your powershell profile: `$env:Path += ";C:\Users\<you>\bin"`
4. Run a pre-flight check first: `flux check --pre`
    - If the version check shows an x, you might need to upgrade flux.
5. `cd` to `./installation/flux/` and run `.\install-flux.ps1 -env local` to deploy the Flux CRDs and assets to your local cluster. This can take a couple of minutes, it's pulling down a bunch of images.
    - You can check its progress via `kubectl get pods -n flux-system`.
    
    ```powershell
    ~#@❯  kubectl get pods -n flux-system                          ❮  1m 4s 305ms 
    NAME                                           READY   STATUS    RESTARTS   AGE
    helm-controller-85bfd4959d-zwnkq               1/1     Running   0          2m7s
    image-automation-controller-664c74dcd7-jvsp5   1/1     Running   0          2m7s
    image-reflector-controller-55fb577bf9-zkvln    1/1     Running   0          2m7s
    kustomize-controller-5687758989-rst6x          1/1     Running   0          2m7s
    source-controller-ccd98ccf6-fpcsp              1/1     Running   0          2m7s
    notification-controller-758d759586-bfkgn       1/1     Running   0          2m7s
    ```
    
6. Now it's time to create the source, which will be your forked repo of this upstream, so flux knows where its configuration is.
    - create a new SSH key locally that we'll use for flux deployments (name the ssh file something like flux-deploy-key). See https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent for detailed steps to follow. Be sure to also add your ssh key to the ssh-agent: `ssh-add ~/.ssh/flux-deploy-key`.
    
    - In Github, fork from kavm and create your own new repo. Name it: `yourname-kavm`.
    - set your upstream (name branch 'main') and push to origin. `git remote add origin https://github.com/<yourgithubname>/<yourname>-kavm.git ` then `git push -u origin main -f`
    - Go to the repo and go to settings->deploy keys. Get the contents of your flux-deploy-key public file and upload it to the repo.
    - Run `.\create-source.ps1 ssh://git@github.com/<your-github-account-name/<yourname>-kavm <path-to-private-key> <passphrase>` (for other sources, see https://fluxcd.io/docs/cmd/flux_create_source_git/). The path should be a full path ` c:\users\<you>\.ssh\flux-deploy-key`
7. Let's verify our source is setup correctly with `flux get source git`.
8. You're expecting a similar output to;    
    
    ```powershell   
    your-pc:~/git/kavm/installation/flux$ flux get source git
    NAME            READY   MESSAGE              REVISION                            SUSPENDED 
    kavm       True    Fetched revision: main/971591a975                      False 
    ```

9.  Push any changes to your repo with `git add ../.. && git commit -m "add folder skeleton for flux" && git push --set-upstream origin main`.
10. Make sure flux is up to date with `flux reconcile source git kavm`.
11. Finally, we can bootstrap Flux. This will add kustomizations to you local configuration. Add them and then push your config.
    
    ```powershell
    ./bootstrap-flux.ps1 -Environment local
    git add ../..
    git commit -m "completion of flux bootstrapping"
    git push
    ```
 > NB: If you get an error here saying kustomization file already exists, delete the kustomization.yaml file in clusters/local/flux-system
   
    - Flux should already be provisioning the cluster to make it consistent with the local configuration.
    
```powershell
   ~#@❯  k get all -A     
NAMESPACE        NAME                                                       READY   STATUS              RESTARTS   AGE
kube-system      pod/calico-kube-controllers-847c8c99d-r5h29                1/1     Running             0          16m
kube-system      pod/calico-node-s95gp                                      1/1     Running             0          16m
kube-system      pod/coredns-86f78bb79c-9f7hc                               1/1     Running             0          14m
kube-system      pod/hostpath-provisioner-5c65fbdb4f-zgqjn                  1/1     Running             0          14m
flux-system      pod/helm-controller-85bfd4959d-zwnkq                       1/1     Running             0          11m
flux-system      pod/image-automation-controller-664c74dcd7-jvsp5           1/1     Running             0          11m
flux-system      pod/image-reflector-controller-55fb577bf9-zkvln            1/1     Running             0          11m
flux-system      pod/kustomize-controller-5687758989-rst6x                  1/1     Running             0          11m
flux-system      pod/source-controller-ccd98ccf6-fpcsp                      1/1     Running             0          11m
flux-system      pod/notification-controller-758d759586-bfkgn               1/1     Running             0          11m
kube-system      pod/kubernetes-dashboard-7d84465658-65qm6                  0/2     ContainerCreating   0          32s
default          pod/ingress-nginx-admission-create-2phbg                   0/1     ContainerCreating   0          32s
metallb-system   pod/metallb-speaker-drl27                                  0/1     ContainerCreating   0          31s
metallb-system   pod/metallb-controller-6594954f49-sbrl8                    0/1     ContainerCreating   0          31s
postgresql       pod/postgresql-postgresql-0                                0/1     Init:0/1            0          31s
kube-system      pod/kubernetes-dashboard-metrics-server-7bc85c65bc-7zscw   0/1     Running             0          32s

NAMESPACE     NAME                                          TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)                  AGE
default       service/kubernetes                            ClusterIP      10.152.183.1     <none>        443/TCP                  17m
kube-system   service/kube-dns                              ClusterIP      10.152.183.10    <none>        53/UDP,53/TCP,9153/TCP   14m
kube-system   service/kubernetes-dashboard-metrics-server   ClusterIP      10.152.183.79    <none>        443/TCP                  32s
kube-system   service/kubernetes-dashboard                  LoadBalancer   10.152.183.213   <pending>     443:30253/TCP            32s
postgresql    service/postgresql-headless                   ClusterIP      None             <none>        5432/TCP                 31s
postgresql    service/postgresql                            LoadBalancer   10.152.183.21    <pending>     5432:30032/TCP           31s
flux-system   service/notification-controller               ClusterIP      10.152.183.16    <none>        80/TCP                   11m
flux-system   service/source-controller                     ClusterIP      10.152.183.207   <none>        80/TCP                   11m
flux-system   service/webhook-receiver                      ClusterIP      10.152.183.44    <none>        80/TCP                   11m
```
Above you can see that pods are still in the midst of being created. And the external-ip values haven't been assigned to k8s-dashboard or postgresql yet.. Wait a minute and check everything is 1/1 and ips are assigned before going to the next step.

1.   Setup your [hosts file so that you can browse to relevant apps](../../documentation/setup-hosts-file.md)) 
2.   With Flux now keeping your local k8s cluster in sync with the source repo, we can now login to the k8s dashboard.
    - In a browser go to https://dashboard.local.kavm.com.au (must be https)
    - choose the kube config login option to auth into the dashboard.
> If you want to go the token route, you will need to apply these 2 yaml files manually into your cluster via: `k apply -f .\dashboard-service-account.yaml` && `k apply -f .\dashboard-cluster-role-binding.yaml`. For more info, see: https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md.
1.    Setup flux autocomplete:
    - Taken from the guide here: https://fluxcd.io/docs/cmd/flux_completion_powershell/, paste this into your profile:

```powershell
cd "$env:USERPROFILE\Documents\PowerShell\Modules"
flux completion powershell > flux-completion.ps1
.\flux-completion.ps1

cd -
```

## Troubleshooting

If flux fails to install, upgrade it:

``` ~#@❯  ./install-flux.ps1 -env local                                                                                                                                                                                                                                                                                                         ❮  
namespace/flux-system created
✗ targeted version 'v0.34.0' is not compatible with your current version of flux (0.33.0)
✗ targeted version 'v0.34.0' is not compatible with your current version of flux (0.33.0)
```

Flux wont resync your environment with the latest origin commits if you force rebase. (it seems to do so for pods but not for services/ingress) 
### If things just aren't deploying

1. There are several kustomizations, to list them and check they're all deploying as we expect:
    - `flux get kustomizations` 
  
```text
NAME            READY   MESSAGE                                                                 REVISION                                        SUSPENDED
flux-system     True    Applied revision: main/cb4c0cb86881c7614aacdcb90f93bec7307739b9       main/cb4c0cb86881c7614aacdcb90f93bec7307739b9 False
sources         True    Applied revision: main/cb4c0cb86881c7614aacdcb90f93bec7307739b9       main/cb4c0cb86881c7614aacdcb90f93bec7307739b9 False
apps            True    Applied revision: main/cb4c0cb86881c7614aacdcb90f93bec7307739b9       main/cb4c0cb86881c7614aacdcb90f93bec7307739b9 False
infrastructure  True    Applied revision: main/cb4c0cb86881c7614aacdcb90f93bec7307739b9       main/cb4c0cb86881c7614aacdcb90f93bec7307739b9 False
```

2. Dump the logs for the kustomize and helm controllers to start with:
    - e.g.  `kubectl logs helm-controller-85bfd4959d-99kv7 -n flux-system` 

3. Validate your kustomize build to see if there's any errors (and fix them)
   
   expected output:
```❯ ./validate.sh local
running validate
linting base
linting local
building local using kustomize
split: infrastructure/local: Is a directory
split: apps/local: Is a directory
```

4. Helm charts are trying to bring down a new version of an image that's incompatible (breaking changes) with what's in the kustomization files.
   - Go online and find the helm chart
   - Add the repo locally via helm: e.g. `helm repo add bitnami https://charts.bitnami.com/bitnami`
   - Get the current values.yaml file from the chart: e.g. `helm show values bitnami/postgresql > values.yanml`
   - Map over the current values.yaml file as best as you can. (note: you can remove parameters in values.yaml that you haven't set to a custom value)
   - In a bash shell, run `./validate.sh local` to check formatting and content is valid yaml.
   - Remove the namespace of the service that's not working; e.g. `kubectl delete ns blah`
   - Try and install the helm chart directly (outside of using flux); e.g. `helm install postgresql bitnami/postgresql -f .\values.yaml`
     - If this works, then uninstall the helm chart; e.g. `helm uninstall postgresql`
   - Commit your changes and push to remote. Do a Flux reconcile and see the results.

### Your pod exists but isn't starting

Run a describe on the pod, `kubectl describe pod -l app=name-of-app` or do a `kubectl describe pod <pod-instance-name>`

- Check that the image it pulled down has the right hash of the image you have in your registry. microk8s will use the local image cache and if you've pushed a `:latest` image over the top of an existing (previously pulled down and deployed) image with the same tag, microk8s won't know to get an updated image. To fix this issue, delete the local image via 
  `microk8s ctr images ls`
  `microk8s ctr image rm 6175b95d41f8ba4d9a885a5ca8561bd078917e80602150bc6b5e80578bf2d530` -- example image hash

- If your pod has a readiness probe, check that your app's port that it's running on matches what you've defined in the corresponding deployment.yaml.

### Suspend flux syncing

- If you're repo has issues and you want to manually clean things up in your cluster without having flux auto re-creating things at that time, you can suspend flux syncing for a given kustomization category via: `flux suspend kustomization apps`, `flux suspend kustomization infrastructure`. To resume, `flux resume kustomization apps`


```text
 > flux get kustomizations            
NAME            READY   MESSAGE                                                                                                                                                                                                 REVISION                                        SUSPENDED
infrastructure  False   failed to download artifact from http://source-controller.flux-system.svc.cluster.local./gitrepository/flux-system/kavm/bc21a4bcb73d6f551f1d0c55d0d02d1c44359831.tar.gz, status: 404 Not Found    main/29d03d1d446baeed549d2deeff68e84048308785 False

apps            False   failed to download artifact from http://source-controller.flux-system.svc.cluster.local./gitrepository/flux-system/kavm/bc21a4bcb73d6f551f1d0c55d0d02d1c44359831.tar.gz, status: 404 Not Found    main/29d03d1d446baeed549d2deeff68e84048308785 False

sources         True    Applied revision: main/bc21a4bcb73d6f551f1d0c55d0d02d1c44359831                                                                                                                                       main/bc21a4bcb73d6f551f1d0c55d0d02d1c44359831 False

flux-system     True    Applied revision: main/bc21a4bcb73d6f551f1d0c55d0d02d1c44359831                                                                                                                                       main/bc21a4bcb73d6f551f1d0c55d0d02d1c44359831 False
```
### Uninstall 

To uninstall flux, which will remove everything that it deployed: `flux uninstall`
