FROM cp.icr.io/cp/ibm-eventstreams-kafka:11.4.0

USER root

COPY ./plugins/ /opt/kafka/plugins/

RUN cd /opt/kafka/libs && curl -sO https://jdbc.postgresql.org/download/postgresql-42.7.3.jar

USER 1001