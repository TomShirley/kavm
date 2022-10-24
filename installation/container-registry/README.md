# Setting up a container registry

Go with either option A (Use a cloud container registry) or option B (Use local docker registry)

## Option A - AWS ECR registry

We'll use AWS ecr service for this. The region we're using is sydney but you can change the region in the commands to whatever is relevant to you.


1. Create a new ecr repository in the aws ui console or run the below with a profile that has create ecr rights. `aws ecr create-repository --repository-name <optional-prefix>/%image-name% --profile %some-profile-name-with-ecr-create-permission%`
2. Download and install aws cli: https://aws.amazon.com/cli/
#3. Also install the aws pwsh cmdlets here: https://www.powershellgallery.com/packages/AWSPowerShell.NetCore/4.1.12.0


If you haven't setup a service account user in aws to access the ecr instance, then the steps are:

1. To setup a profile locally so that aws cli can use your selected iam user when pushing images into your ecr registry, run `aws configure`. 
2. Enter the access key and secret of the service account user. If you need to create a new access key, go into iam and generate a new one.
3. Login to aws cli `aws ecr get-login-password --region ap-southeast-2`
   - add `--profile` to the above if you use multiple AWS Accounts
4. We need the location of your ecr repository. To get that, login to aws console and go to your ecr repository instance. Click on the button 'view push commands'.

![push-commands-ui](push-commands-ui.png)

1. Run the step listed to wire-up docker login to the ecr instance, e.g. `aws ecr get-login-password --region ap-southeast-2 | docker login --username AWS --password-stdin <some-place>.dkr.ecr.ap-southeast-2.amazonaws.com`
   
   
## Option B - Use local docker registry

// todo steps: local registry info: https://microk8s.io/docs/registry-built-in

## Setup reference apps!

Next, setup a sample 3-tier application, see [this guide](../setup-api-and-microsite/sample-3-tier-application-guide.md)
