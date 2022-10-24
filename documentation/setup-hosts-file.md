# Setting up your hosts file 

Now we need to edit our `c:\windows\system32\drivers\etc\hosts` file to point our hostnames for our local cluster to the IP's that were assigned to the services;

As an example config in hosts:
```
...
192.168.1.230     postgresql.local.kavm.com.au
192.168.1.231     ingress.local.kavm.com.au
192.168.1.232     dashboard.local.kavm.com.au
192.168.1.233     mssql.local.kavm.com.au
```

The external IP that was assgined to `mssql` should be assigned to:

* mssql.local.kavm.com.au

The external IP that was assgined to `postgresql` should be assigned to:

* postgresql.local.kavm.com.au

The external IP that was assgined to `kubernetes-dashboard` should be assigned to:

* dashboard.local.kavm.com.au


The external IP that was assgined to `ingress-nginx-controller` should be assigned to:

* ingress.local.kavm.com.au


