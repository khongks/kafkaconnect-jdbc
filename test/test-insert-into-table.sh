#!/bin/bash

export CUSTOMER_NAME=${1:-"Peter Parker"}
export CUSTOMER_AGE=${2:-19}
export CUSTOMER_PHONE=${3:-"96348373"}
export PG_TABLE_NAME=${4:-customers}

export PG_DATABASE_NAME=${5:-demo}
export PG_INSTANCE_NAME=${6:-postgresql}
export PG_NAMESPACE=${7:-postgresql}

export POSTGRES_PORT=`oc get svc -n $PG_NAMESPACE $PG_INSTANCE_NAME -ojson | jq -r '.spec.ports[].nodePort'`
export POSTGRES_IP=`dig +short $(oc get route -n openshift-console console -ojson | jq -r '.status.ingress[].routerCanonicalHostname')`
psql -U postgres -h $POSTGRES_IP -p $POSTGRES_PORT -d $PG_DATABASE_NAME -c "INSERT INTO $PG_TABLE_NAME (name, age, phone) VALUES ('$CUSTOMER_NAME', $CUSTOMER_AGE, '$CUSTOMER_PHONE');"