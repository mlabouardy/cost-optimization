#!/bin/bash

echo "IAM role for StartEnvironment"
arn=$(aws iam create-policy --policy-name StartEnvironment --policy-document file://start/policy.json | jq -r '.Policy.Arn')
result=$(aws iam create-role --role-name StartEnvironmentRole --assume-role-policy-document file://role.json | jq -r '.Role.Arn')
aws iam attach-role-policy --role-name StartEnvironmentRole --policy-arn $arn 
echo "ARN: $result"

echo "IAM role for StopEnvironment"
arn=$(aws iam create-policy --policy-name StopEnvironment --policy-document file://stop/policy.json | jq -r '.Policy.Arn')
result=$(aws iam create-role --role-name StopEnvironmentRole --assume-role-policy-document file://role.json | jq -r '.Role.Arn') 
aws iam attach-role-policy --role-name StopEnvironmentRole --policy-arn $arn
echo "ARN: $result"