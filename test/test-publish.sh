#!/bin/bash

export ES_INSTANCE=esminimal
export ES_KAFKA_USER=kafka-client
export ES_NAMESPACE=integration
export ES_TOPIC=transactions

export ES_BOOTSTRAP_HOST=`oc get route -n $ES_NAMESPACE $ES_INSTANCE-kafka-bootstrap -ojson | jq -r '.status.ingress[].host'`
export ES_BOOTSTRAP_PORT=443
export ES_KAFKA_USERPASSWORD=`oc get secret -n $ES_NAMESPACE $ES_KAFKA_USER -ojson | jq -r '.data.password' | base64 -d`

export CA_CRT=`oc get secret -n $ES_NAMESPACE $ES_INSTANCE-cluster-ca-cert -ojson | jq -r '.data."ca.crt"' | base64 -d`

cat << EOF > ca.crt
$CA_CRT
EOF

let offset=0
if test -f transactions.offset; then
  echo "transactions.offset file found"
  offset=`cat transactions.offset`
fi
echo "offset: ${offset}"

cat << EOF > transaction.json
{"schema":{"type":"struct","fields":[{"type":"int64","optional":false,"field":"id"},{"type":"string","optional":false,"field":"account_no"},{"type":"string","optional":false,"field":"trans_type"},{"type":"int64","optional":false,"field":"amount"},{"type":"string","optional":false,"field":"currency"}]},"payload":{"id":${offset},"account_no":"4444444","trans_type":"Deposit","amount":2900,"currency":"AUD"}}
EOF

cat << EOF > test-publish.conf
bootstrap.servers=$ES_BOOTSTRAP_HOST:$ES_BOOTSTRAP_PORT
ssl.ca.location=ca.crt
security.protocol=SASL_SSL
sasl.mechanisms=SCRAM-SHA-512
sasl.username=$ES_KAFKA_USER
sasl.password=$ES_KAFKA_USERPASSWORD
EOF

cat transaction.json | kcat \
  -t $ES_TOPIC \
  -F test-publish.conf \
  -P

((offset++))
echo "new offset: ${offset}"
cat << EOF > transactions.offset
${offset}
EOF