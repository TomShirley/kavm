# MS SQL setup guide

This helm chart was taken from https://github.com/microsoft/mssql-docker

Because I couldn't find an online helm registry that was hosting this chart, i've temporarily copied down the helm chart files and from the above repo and modified them so that they can use microk8s storageClass, see value.yaml ` StorageClass: "microk8s-hostpath"`

For now, manually install this helm chart to stand up ms-sql:
    - cd into this dir
    - create a namespace: `k apply -f .\namespace.yaml `
    - change to the mssql namespace before running the install:
    - install the chart: `helm install mssql-latest-deploy .`


TODO: Move this chart to a self-hosted helm registry (maybe using https://github.com/helm/chartmuseum) (or is there a native way in microk8s/k8s to host charts)


## How to import an existing database into microk8s local mssql

- In SSMS, right click the db you want to export and select tasks->'Export data-tier application'
- Connect to your mssql external ip in SSMS, typically 192.1.8.1.233 with the sa user
- Import the saved backpac file
- Probably need to wire up the login for the database you imported (reset it's password)


## Troubleshooting

* If you have deleted the database and can't re-import a new one because the database files already exist on disk, you can attach to the pod and delete via a shell, i.e.

```
mssql@mssqllatest:/var/opt/mssql/data$ ls
Entropy.bin  blogsdb.ldf  blogsdb.mdf  master.mdf  mastlog.ldf  model.mdf  model_msdbdata.mdf  model_msdblog.ldf  model_replicatedmaster.ldf  model_replicatedmaster.mdf  modellog.ldf  msdbdata.mdf  msdblog.ldf  tempdb.mdf  templog.ldf
```
  