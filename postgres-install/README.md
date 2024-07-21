# Instructions to install and create PostgreSQL database for the purpose of this tutorial

## Tools

1. psql - installation instructions found [here](https://www.timescale.com/blog/how-to-install-psql-on-mac-ubuntu-debian-windows/)


## Install PostgreSQL database

1. Go to the folder `postgres-install` where I have prepare all the yaml files needed to install PostgreSQL.

```
$ oc new-project postgresl
$ oc apply -k .

configmap/postgresql-extended-config created
secret/postgresql-secret created
service/postgresql created
statefulset.apps/postgresql created
```

2. Check it is up and running

```
$ oc get po -n postgresql

NAME           READY   STATUS    RESTARTS   AGE
postgresql-0   1/1     Running   0          64s
```

## Create a `demo` database

1. Connect to the PostgreSQL via the NodePort

   1. Get Node Port
   ```
   $ export POSTGRES_PORT=`oc get svc -n postgresql postgresql -ojson | jq -r '.spec.ports[].nodePort'`
   ```

   2. Get IP address
   ```
   $ export POSTGRES_IP=`dig +short $(oc get route -n openshift-console console -ojson | jq -r '.status.ingress[].routerCanonicalHostname')`
   ```

   3. Connect to PostgreSQL
   ```
   $ psql --username postgres --port=$POSTGRES_PORT --host=${POSTGRES_IP}
   ```

   4. Create `demo` database
   ```
   # CREATE DATABASE demo;
   
   CREATE DATABASE
   ```

   5. Connect to `demo` database
   ```
   # \c demo;

   psql (16.2, server 14.11)
   You are now connected to database "demo" as user "postgres".
   ```

---

## References: 

- PostgreSQL commands [cheat sheet](https://www.postgresqltutorial.com/postgresql-cheat-sheet/)
- PostgreSQL [timestamp](https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-timestamp/)