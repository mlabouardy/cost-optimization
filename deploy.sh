#!/bin/bash

START_IAM_ROLE="arn:aws:iam::ACCOUNT_ID:role/StartEnvironmentRole"
STOP_IAM_ROLE="arn:aws:iam::ACCOUNT_ID:role/StopEnvironmentRole"
AWS_REGION="us-east-1"
SLACK_WEBHOOK="https://hooks.slack.com/services/TOKEN"
ENVIRONMENT="sandbox"

echo "Deploying StartEnvironment to Lambda"
aws lambda create-function --function-name StartEnvironment \
    --zip-file fileb://./start-environment.zip \
    --runtime go1.x --handler main \
    --role $START_IAM_ROLE \
    --environment Variables="{SLACK_WEBHOOK=$SLACK_WEBHOOK,ENVIRONMENT=$ENVIRONMENT}" \
    --region $AWS_REGION


echo "Deploying StopEnvironment to Lambda"
aws lambda create-function --function-name StopEnvironment \
    --zip-file fileb://./stop-environment.zip \
    --runtime go1.x --handler main \
    --role $STOP_IAM_ROLE \
    --environment Variables="{SLACK_WEBHOOK=$SLACK_WEBHOOK,ENVIRONMENT=$ENVIRONMENT}" \
    --region $AWS_REGION \


rm *-environment.zip
