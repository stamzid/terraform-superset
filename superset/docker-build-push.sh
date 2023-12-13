#!/bin/bash

aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
docker build . -t superset:latest

docker tag superset:latest ${REPO_URL}:latest
docker push ${REPO_URL}:latest
