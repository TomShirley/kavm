# Deploy a microsite & microservice sample application 

We'll configure an api running on .net core using EF core, with a database in SQL 2019 within this k8s cluster. We'll also build and configure a microsite running on Angular 11.

1. To manually deploy ms-sql in the local cluster (i.e. outside of using flux), see [this Readme on deploying MS SQL server using a helm chart](../../infrastructure/manual-deploy/mssql/README.md).
2. Setup the .net api by [following this Readme](build-sample-api.md).
3. Setup the Angular ui by [following this Readme](build-sample-ui.md).

With the above steps complete, you should now be able to navigate to http://ingress.local.kavm.com.au/apps/ng-microsite/ . Click on 'Blogs Dashboard' card to see a list of blogs served from the sample api application, which is reading data from an ms-sql database within k8s. 
