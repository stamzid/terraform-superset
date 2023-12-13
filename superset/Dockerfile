FROM apache/superset:latest

USER root

RUN pip install PyAthena

COPY ./entrypoint.sh /entrypoint.sh

USER superset
ENTRYPOINT [ "/entrypoint.sh" ]
