#!/bin/bash

export PG_TABLE_NAME=${1:-customers}
export PG_DATABASE_NAME=${2:-demo}
export PG_INSTANCE_NAME=${3:-postgresql}
export PG_NAMESPACE=${4:-postgresql}

export POSTGRES_PORT=`oc get svc -n $PG_NAMESPACE $PG_INSTANCE_NAME -ojson | jq -r '.spec.ports[].nodePort'`
export POSTGRES_IP=`dig +short $(oc get route -n openshift-console console -ojson | jq -r '.status.ingress[].routerCanonicalHostname')`

psql -U postgres -h $POSTGRES_IP -p $POSTGRES_PORT -d $PG_DATABASE_NAME -c "CREATE TABLE $PG_TABLE_NAME(id SERIAL PRIMARY KEY, name VARCHAR(50), age INT,phone VARCHAR(10), created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP, updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP);"