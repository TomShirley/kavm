# Build the sample Angular app's docker image and push it into ecr

Here are the steps on how you would build the sample Angular app and push the docker image to an ecr registry so that your k8s local cluster can deploy the app via flux.

Pull down the ref-ng-ui repo from github: `ref-ng-ui`

Under the `tools\docker-ng`  folder, there's a Dockerfile that can run angular commands within a container. You can obvisouly run angular cli on your windows terminal without running the commands inside a docker container, but I find this approach more consistent once you want to setup a CI pipeline in an external app like team-city, circleCi.

## Pre-reqs

* Download and install aws cli: https://aws.amazon.com/cli/
* Ensure docker desktop is running

## Setup your ECR repository 

1. Create a new ecr repository in the aws ui console or run the below with a profile that has create ecr rights. `aws ecr create-repository --repository-name %image-name% --profile %some-profile-name-with-ecr-create-permission%`. For this sample app: `aws ecr create-repository --repository-name ref-ng-ui --profile <your-aws-profile>`
2. Next, we need to setup a service account in aws (and setup a profile locally for that service account) so that aws cli can use your selected iam user when pushing images into your ecr registry
    * In AWS UI console, create a new service account in aws and grant that service account user rights to push to ecr.
        * Obtain an access token for the service account.
    * Run `aws configure --profile local-ecr-service-account` in powershell. 
        * Enter the access key and secret of the service account user to setup 
3. We need the location of your ecr repository. To get that, login to aws console and go to your ecr repository instance. Click on the button 'view push commands'.
4. Wire-up docker so that it can push to the ecr repository, e.g. `aws ecr get-login-password --region ap-southeast-2 --profile local-ecr-service-account | docker login --username AWS --password-stdin <your-aws-id>.dkr.ecr.ap-southeast-2.amazonaws.com`

## Build reference Angular microsite

1. Ensure docker desktop is running
2. Navigate into the ref-ng-ui repo you cloned
3. First, cd into `tools/docker-ng` and build docker-ng image: `docker build -t docker-ng .`
   - If this fails with something like: `#7 2.672 error puppeteer-core@18.2.1: The engine "node" is incompatible with this module. Expected version ">=14.1.0". Got "12.22.7"` then update the node image FROM tag in the dockerfile to a newer image version build
4. cd back in the root directory of the repo.
5. Install dependencies: `docker run --init --rm --privileged -it  -v ${pwd}:/src docker-ng /bin/sh -c "yarn"` 
6. Build the ng app: `docker run --init --rm --privileged -it  -v ${pwd}:/src docker-ng /bin/sh -c "yarn  build --prod"`. Probably will take ~2mins to build
7. Let's create the docker image now: `docker build -t ref-ng-ui -f Dockerfile .`
8. login to aws ecr for docker: `aws ecr get-login-password --region ap-southeast-2 | docker login --username AWS --password-stdin <some-place>.dkr.ecr.ap-southeast-2.amazonaws.com`


## Push the angular app to ecr

1. Tag your image: `docker tag ref-ng-ui:latest <YOUR-ACCOUNT-ID>.dkr.ecr.ap-southeast-2.amazonaws.com/ref-ng-ui:latest`
2. Push it up: `docker push <YOUR-ACCOUNT-ID>.dkr.ecr.ap-southeast-2.amazonaws.com/ref-ng-ui:latest`
3. Open `deployment.yaml` in `apps/base/kavm-services/ref-ng-ui` and update the `image:` value to point to your aws instance id.
4. Commit your change and push it to the origin/remote.
5. Run a reconcile so you don't need to wait for flux to sync on schedule: `flux reconcile source git kavm`

## Set ECR token so that k8s can pull down images from your ecr repository

1. We need to create a secret which we'll name 'ecr-access-token`, which will be created in the namespace where your application pod will live inside of.
2. Check that the namespace exists: `kubectl get ns`. If it doesn't exist yet, create it via 
```
$NAMESPACE="kavm-services"
echo @"
apiVersion: v1 
kind: Namespace
metadata:
  name: $NAMESPACE
"@ | kubectl apply -f -
```
3. Create your secret which has the ecr access token:
   
    ```
    $NAMESPACE="kavm-services"
    kubectl create secret docker-registry ecr-access-token -n $NAMESPACE `
    --save-config --dry-run=client -o yaml `
    --docker-server=<your-aws-id>.dkr.ecr.ap-southeast-2.amazonaws.com `
    --docker-username=AWS `
    --docker-password="$(aws ecr get-login-password --region ap-southeast-2)" |
    kubectl apply -f - 

    kubectl patch serviceaccount default -p '{"imagePullSecrets": [{"name": "ecr-access-token"}]}' -n $NAMESPACE
    ```

    Note: if the patch above fails with a 400, try this instead:

    ```powershell
    $NAMESPACE="kavm-services"
    kubectl get serviceaccount default -o yaml -n $NAMESPACE > temp.yaml
    ```

    Now, remove this `resourceVersion: "118581"` from the yaml file and add in the imagePullSecret section manually:

```imagePullSecrets:
- name: ecr-access-token
```

    see for more info: https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/

    run:

    ```powershell
    kubectl replace serviceaccount default -f temp.yaml -n $NAMESPACE
    ```

4. Now, delete the pods if they already exist and are stuck pulling the image down. flux/k8s will recreate them straight away. Do a `describe` on the pods, they should now be able to pull down your image from ecr.

>
> If the pod wont start, and you've deleted any local images (incase it's not pulling down latest), via `microk8s ctr images rm <blah>.dkr.ecr.ap-southeast-2.amazonaws.com/ref-ng-ui@sha256:fd6f2e4d7833cc761a5344cb08fb117159e6baf36156e09e6207ff8ef415e04e`, then get the logs of the pod: ` k logs ref-ng-ui-76898db6db-dxqfm`

5. Test the site in a browser
   - Go to http://ingress.local.kavm.com.au/apps/ng-microsite/


## Troubleshooting

If you see ImagePullBackOff, it's most likely you need to reapply the ecr secret into the right namespace:

```text
> k get pods
NAME                                      READY   STATUS             RESTARTS   AGE
ref-net-core-api-c87d6d677-hlgmj     1/1     Running            1          23h
ref-ng-ui-76898db6db-fww7n   0/1     ImagePullBackOff   0          2m40s
```

- Another thing to check is if your AWS user that you're using to login to aws from the cli has permissions to pull from your ecr container registry. Go into aws web console->IAM and make sure the user who's access token you are using has permissions 'AmazonEC2ContainerRegistryReadOnly'. This is shown in the group attached to your user.

* Pod won't ready up:

```text
>  k get pods                                                                                      
NAME                                      READY   STATUS             RESTARTS   AGE
ref-net-core-api-c87d6d677-hlgmj     1/1     Running            1          23h
ref-ng-ui-76898db6db-spjbf   0/1     CrashLoopBackOff   6          8m17s
```

```text
Containers:
  ref-ng-ui:
    Container ID:   containerd://8096c90f97c57b10795a2f2aa39b6780e46e7ec00ac10900d0df7c3d5b9f651a
    Image:          <YOUR-ACCOUNT-ID>.dkr.ecr.ap-southeast-2.amazonaws.com/ref-ng-ui:latest
    Image ID:       <YOUR-ACCOUNT-ID>.dkr.ecr.ap-southeast-2.amazonaws.com/ref-ng-ui@sha256:fd6f2e4d7833cc761a5344cb08fb117159e6baf36156e09e6207ff8ef415e04e
    Port:           80/TCP
    Host Port:      0/TCP
    State:          Waiting
      Reason:       CrashLoopBackOff
    Last State:     Terminated
      Reason:       Error
      Exit Code:    1
      Started:      Thu, 03 Jun 2021 22:06:56 +1000
      Finished:     Thu, 03 Jun 2021 22:06:56 +1000
    Ready:          False
    Restart Count:  3
    Limits:
      memory:  64Mi
    Requests:
      memory:     10Mi
    Liveness:     http-get http://:80/ delay=30s timeout=30s period=10s #success=1 #failure=3
    Readiness:    http-get http://:80/ delay=30s timeout=30s period=10s #success=1 #failure=3
    Environment:  <none>
```

Check that your ingress is setup right as k8s doesn't seem to be about to hit the readiness endpoint.

inspect the logs of the nginx ingress controller:
`k logs nginx-ingress-microk8s-controller-wxdbn`


