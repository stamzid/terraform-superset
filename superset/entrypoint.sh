#!/bin/bash

superset fab create-admin --username "$ADMIN_USERNAME" --firstname Superset --lastname Admin --password "$ADMIN_PASSWORD" --email admin@superset.com
superset db upgrade
superset init

# Starting server
/bin/sh -c /usr/bin/run-server.sh
