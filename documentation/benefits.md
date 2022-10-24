# Benefits of adopting k8s with git-ops

The intent of using kavm as a platform for CD is:

- By adopting k8s you'll have a microsite/microservice platform that can be managed by small dev teams even when there's 100s of apps. 
- With containers and k8s you can start to move towards a mecha-service architecture: see https://www.infoq.com/articles/multi-runtime-microservice-architecture/. In essence, make changes via configuration instead of code for orthogonal concerns to your app (like auth, logging, monitoring), which run as sidecars (out-of-process) so they can be controlled uniformly and updated seperately to your app.
- Reduce the time in setting everything up to deploy your app across environments. This repo helps you write automated deployment artifacts that keeps your application components consistent across environments. 
- Flux keeps your environments synchronized with this repo. Get git-ops goodness that helps you deploy apps across your enterprise in an automated way (your apps will need to be containerized so that this repo can pull them down from a repo registry somewhere). 
- Flux as a CD tool allows you to PR changes to your environments which is a better approach than doing change mgmt without git.
- Building/changing an app in isolation is hard when there are many external dependancies. Typically, you may decide to configure the local application to point to external dependancies to a higher environment (like your dev/test env). But what if those environments are broken (which is blocking you from making the change you need to make), or the change you need to implement is going to require updates to multiple repos. How do you manage that change currently? Do you pull down all the repos and try and stand things up, one by one, and hope someone wrote down steps in a readme, confluence, back of the unisex toilet door? Spend a day struggling to install dependencies on your machine, from some random share that someone has dumped exe files on. The pain of it all.
    
    An alternative? 

    * Containerize your apps, deploy them into k8s. Run k8s locally. Make the code changes in all of the repos you need to. Test out your changes locally. They look good? Great, commit and PR those repos and have your higher environments updated based on semver rules automatically without needing to do anything. 
    * The difference here is that you're not relying on a higher environment to do your testing, you've done it all locally and because your k8s environments are described upfront in this repo, when your apps get pushed into higher environments things should just work. 
  
- Deploying apps into k8s is a very speedy proposition. Usually less than a minute to deploy your new app from a container registry.
- Your app ecosystem is described in this repo (desired state). If you have a DR scenario where you need to bring everything back up from scratch it's painless with k8s. 
- You can move devops work into the development teams to manage, as they're implmenting their application, which is the best place for this work to occur. The aim is for self-service infrastructure for dev teams (where it makes sense).
- Traffic between apps deployed within your environment can stay within the k8s network and doesn't need to go out through the internet, and you get mTLS down into your application.
