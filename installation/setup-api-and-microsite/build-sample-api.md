# Build the sample .netcore app's docker image and push it into ecr

Steps below walk you through building the sample .net-core 5.0 app and pushing the docker image to an aws ecr registry so that your k8s local cluster can deploy the app via flux.

First off, clone the ref-net-core-api repo from github: [tomshirley/ref-net-core-api](https://github.com/TomShirley/ref-net-core-api)

## Pre-reqs

* Download and install aws cli: <https://aws.amazon.com/cli/>
* Ensure docker desktop is running

## Setup your ECR repository

1. Create a new ecr repository in the aws ui console or run the below with a profile that has create ecr rights. `aws ecr create-repository --repository-name %image-name% --profile %some-profile-name-with-ecr-create-permission%`. For this sample app: `aws ecr create-repository --repository-name ref-net-core-api --profile <your-aws-profile>`
2. Next, we need to setup a service account in aws (and setup a profile locally for that service account) so that aws cli can use your selected iam user when pushing images into your ecr registry
    * In AWS UI console, create a new service account in aws and grant that service account user rights to push to ecr.
        * Obtain an access token for the service account.
    * Run `aws configure --profile local-ecr-service-account` in powershell.
        * Enter the access key and secret of the service account user to setup
3. We need the location of your ecr repository. To get that, login to aws console and go to your ecr repository instance. Click on the button 'view push commands'.
4. Wire-up docker so that it can push to the ecr repository, e.g. `aws ecr get-login-password --region ap-southeast-2 --profile local-ecr-service-account | docker login --username AWS --password-stdin <your-aws-id>.dkr.ecr.ap-southeast-2.amazonaws.com`

## Build a docker image of the sample app

1. Navigate into the ref-net-core-api repo you cloned
3. First, cd into `tools/docker-netcore` and build docker-netcore image: `docker build -t docker-netcore:5.0 .`
4. `cd` back in the root directory of the repo.
5. The dotnet image is now ready to be used for local test/build/publish/vuln scanning. Let's build our app first.
    * cd into your application directory and run `docker run --rm -it -v ${pwd}/src:/src docker-netcore:5.0 dotnet build`
        * If you hit any issues, check that your volume mount in the above command is setup right. i.e. `-v ${pwd}/src:/src` is telling docker to make available your `<current-working-directory>/src` path and bind it into the container's root level folder by the name of `/src`.
6. With donet 5 we can do package scanning now too, via: `docker run --rm -it -v ${pwd}/src:/src docker-netcore:5.0 dotnet list package --vulnerable`
7. If things are building fine, we can publish the dotnet app: `docker run --rm -it -v ${pwd}/src:/src docker-netcore:5.0 dotnet publish -c Release`
8. With the application published we will create a docker image of the api. To build your api image, cd into the `...Endpoint` folder and run `docker build -t ref-net-core-api -f Dockerfile .`
   > For more info on dockerfiles, have a look at [this microsoft article on dockerizing a .net core app]> (<https://docs.microsoft.com/en-us/dotnet/core/docker/build-container?tabs=windows#create-the-dockerfile>).

> You could run dotnet your pc directly without running the commands inside a docker container, but this approach is more consistent as it works in CI pipeline tools (e.g. team-city, circleCi, github actions).

## Push image to ecr

1. Tag your built app image, `docker tag <your-app-image-name>:latest <your-aws-instance>.dkr.ecr.ap-southeast-2.amazonaws.com/<repository-name>:latest`, which for this sample app is `docker tag ref-net-core-api:latest <YOUR-ACCOUNT-ID>.dkr.ecr.ap-southeast-2.amazonaws.com/ref-net-core-api:latest`
2. Push your image to your ecr instance, `docker push <your-aws-instance>.dkr.ecr.ap-southeast-2.amazonaws.com/<repository-name>:latest`, e.g. `docker push <your-aws-instance>.dkr.ecr.ap-southeast-2.amazonaws.com/ref-net-core-api:latest`
3. Open `deployment.yaml` in `apps/base/kavm-services/ref-net-core-api` and update the `image:` value to point to your aws instance id.
4. Commit your change and push it to the origin/remote.
5. Run a reconcile so you don't need to wait for flux to sync on schedule: `flux reconcile source git kavm`

## Set ECR token so that k8s can pull down images from your ecr repository

1. We need to create a secret which we'll name 'ecr-access-token`, which will be created in the namespace where your application pod will live inside of.
2. Check that the namespace exists: `kubectl get ns`. If it doesn't exist yet, create it via

    ```bash
    $NAMESPACE="kavm-services"
    echo @"
    apiVersion: v1 
    kind: Namespace
    metadata:
    name: $NAMESPACE
    "@ | kubectl apply -f -
    ```

3. Create your secret which has the ecr access token:

    ```bash
    $NAMESPACE="kavm-services"
    kubectl create secret docker-registry ecr-access-token -n $NAMESPACE `
    --save-config --dry-run=client -o yaml `
    --docker-server=<your-aws-id>.dkr.ecr.ap-southeast-2.amazonaws.com `
    --docker-username=AWS `
    --docker-password="$(aws ecr get-login-password --region ap-southeast-2)" |
    kubectl apply -f - 

    kubectl patch serviceaccount default -p '{"imagePullSecrets": [{"name": "ecr-access-token"}]}' -n $NAMESPACE
    ```

    :grey_exclamation: if the patch above fails with a 400, try this instead:

    * Get the serviceaccount yaml output:

        ```powershell
        $NAMESPACE="kavm-services"
        kubectl get serviceaccount default -o yaml -n $NAMESPACE > temp.yaml
        ```

    * Next, remove `resourceVersion: "118581"` from the yaml file and add in the imagePullSecret section manually:

        ```yaml
        imagePullSecrets:
          - name: ecr-access-token
        ```

    * now replace the existing serviceaccount:

        ```powershell
        kubectl replace serviceaccount default -f temp.yaml -n $NAMESPACE
        ```

    > :information_source: see for more info: <https://kubernetes.io/docs/tasks>    configure-pod-container/configure-service-account/

4. Now, delete the pods if they already exist and are stuck pulling the image down. flux/k8s will recreate them straight away. Do a `describe` on the pods, they should now be able to pull down your image from ecr.

> If the pod wont start, and you've deleted any local images (incase it's not pulling down latest), via `microk8s ctr images rm <blah>.dkr.ecr.ap-southeast-2.amazonaws.com/ref-ng-ui@sha256:fd6f2e4d7833cc761a5344cb08fb117159e6baf36156e09e6207ff8ef415e04e`, then get the logs of the pod: e.g. `k logs ref-net-core-api-76898db6db-dxqfm`

* If the pod wont ready up and you see the pod's status as 'ErrImagePull', then:
  * Do a describe and check the event logs: e.g. `k describe pod ref-net-core-api-855b755cc8-rdm9h`. This can show a 401 issue with getting the image:

    ```Events:
    Type     Reason   Age                    From     Message
    ----     ------   ----                   ----     -------
    Normal   Pulling  3m28s (x4 over 5m49s)  kubelet  Pulling image "<YOUR-ACCOUNT-ID>.dkr.ecr.ap-southeast-2.amazonaws.com/ref-net-core-api:latest"
    Warning  Failed   3m27s (x4 over 5m2s)   kubelet  Failed to pull image "<YOUR-ACCOUNT-ID>.dkr.ecr.ap-southeast-2.amazonaws.com/ref-net-core-api:latest": rpc error: code = Unknown desc = failed to pull and unpack image "<YOUR-ACCOUNT-ID>.dkr.ecr.ap-southeast-2.amazonaws.com/ref-net-core-api:latest": failed to resolve reference "<YOUR-ACCOUNT-ID>.dkr.ecr.ap-southeast-2.amazonaws.com/ref-net-core-api:latest": pulling from host <YOUR-ACCOUNT-ID>.dkr.ecr.ap-southeast-2.amazonaws.com failed with status code [manifests latest]: 401 Unauthorized
    Warning  Failed   3m27s (x4 over 5m2s)   kubelet  Error: ErrImagePull
    Warning  Failed   3m12s (x6 over 5m1s)   kubelet  Error: ImagePullBackOff
    Normal   BackOff  42s (x16 over 5m1s)    kubelet  Back-off pulling image "<YOUR-ACCOUNT-ID>.dkr.ecr.ap-southeast-2.amazonaws.com/ref-net-core-api:latest"
    ```

    Check that you have the imagePullSecrets section defined in the service account. And also check that the user access token you are using has permissions to access the ecr; Go into aws web console->IAM and make sure the user who's access token you are using has permissions 'AmazonEC2ContainerRegistryReadOnly'. This is shown in the group attached to your user.

## Import the database

Using SSMS, import the bacpac file (that can be found within repo). When you connect to the mssql server instnace in ssms, use the external ip of mssql service running in your local k8s cluster. You can get the external IP of mssql via: `k get services -A`. The SA password is in `values.yaml` in the mssql folder.

note: If it's stuck on importing screen and doesn't finish, just ignore it and cancel. The tables and data should be there it's an issue with memory usage and sql/ssms when doing a bacpac import.

Check that there's a login on the sql server called 'blog_app' and it's assigned owner access to the db. Reset it's password to the value used in `apps\base\kavm-services\ref-net-core-api\ref-net-core-api-db-connection-configmap.yaml`

## Test the api out

* Hit the api via postman, the url should be: <http://ingress.local.kavm.com.au/api/ref-app/blogs> and you should see a list of blog records returned.
  * If you get nothing back, see [Troubleshooting](#troubleshooting) section.

## Troubleshooting

* I've checked the logs but the pod is just showing the nginx welcome page when trying to hit the api.
  * change into the namespace of the pod first, then get a shell into one of the pods and poke around: `kubectl exec <dot-net-core-pod> --stdin --tty -- /bin/bash` or `kubectl exec -i -t -n kavm-services <pod name> -c ref-net-core-api -- sh -c "clear; (bash || ash || sh)"`

> If the pod wont start, and you've deleted any local images (incase it's not pulling down latest), via `microk8s ctr images rm <blah>.dkr.ecr.ap-southeast-2.amazonaws.com/ref-net-core-api@sha256:fd6f2e4d7833cc761a5344cb08fb117159e6baf36156e09e6207ff8ef415e04e`, then get the logs of the pod: e.g. `k logs ref-net-core-api-76898db6db-dxqfm`

* If you get nothing back, check if the api is working locally; get a shell into one of the pods and poke around: e.g.

    ```bash
        kubectl exec -i -t -n kavm-services ref-net-core-api-855b755cc8-xfs5h -c ref-net-core-api -- sh -c "clear; (bash || ash || sh)" 
    ```

    Install curl and hit the api locally:

    ```bash
    apt update
    apt install curl
    curl localhost:8430/blogs
    ```

    do check the logs of the pod to see if there's a database error if you're notgetting anything back:
    e.g.

    ```text
    fail: Microsoft.AspNetCore.Server.Kestrel[13]
          Connection id "0HMLCMMP8JLGL", Request id "0HMLCMMP8JLGL:00000002": An unhandled exception was thrown by the application.
          Microsoft.Data.SqlClient.SqlException (0x80131904): Login failed for user 'blog_app'.
             at Microsoft.Data.SqlClient.SqlInternalConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)
             at Microsoft.Data.SqlClient.TdsParser.ThrowExceptionAndWarning(TdsParserStateObject stateObj, Boolean callerHasConnectionLock, Boolean asyncClose)
    ```

    If it works fine locally but outside of the k8s network it doesn't work, then check that your ingress is setup right as k8s doesn't seem to be about to hit the readiness endpoint.
