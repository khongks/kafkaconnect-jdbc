#!/bin/bash

export PG_INSTANCE_NAME=postgresql
export PG_NAMESPACE=postgresql
export PG_DATABASE_NAME=demo
export PG_TABLE_NAME=from_kafka_transactions

export POSTGRES_PORT=`oc get svc -n $PG_NAMESPACE $PG_INSTANCE_NAME -ojson | jq -r '.spec.ports[].nodePort'`
export POSTGRES_IP=`dig +short $(oc get route -n openshift-console console -ojson | jq -r '.status.ingress[].routerCanonicalHostname')`
psql -U postgres -h $POSTGRES_IP -p $POSTGRES_PORT -d $PG_DATABASE_NAME -c "SELECT * FROM $PG_TABLE_NAME"