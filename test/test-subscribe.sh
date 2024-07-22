#!/bin/bash

export ES_TOPIC=${1:-from-db-customers}
export ES_KAFKA_USER=${2:-kafka-client}
export ES_INSTANCE=${3:-esminimal}
export ES_NAMESPACE=${4:-integration}

export ES_BOOTSTRAP_HOST=`oc get route -n $ES_NAMESPACE $ES_INSTANCE-kafka-bootstrap -ojson | jq -r '.status.ingress[].host'`
export ES_BOOTSTRAP_PORT=443
export ES_KAFKA_USERPASSWORD=`oc get secret -n $ES_NAMESPACE $ES_KAFKA_USER -ojson | jq -r '.data.password' | base64 -d`

let offset=0
if test -f customers.offset; then
  echo "customers.offset file found"
  offset=`cat customers.offset`
fi
echo "offset: ${offset}"

cat << EOF > test-subscribe.conf
bootstrap.servers=$ES_BOOTSTRAP_HOST:$ES_BOOTSTRAP_PORT
ssl.ca.location=ca.crt
security.protocol=SASL_SSL
sasl.mechanisms=SCRAM-SHA-512
sasl.username=$ES_KAFKA_USER
sasl.password=$ES_KAFKA_USERPASSWORD
EOF

kcat \
  -t $ES_TOPIC \
  -F test-subscribe.conf \
  -C \
  -m 60 \
  -o $offset \
  -c 1

((offset++))
echo "new offset: ${offset}"
cat << EOF > customers.offset
${offset}
EOF