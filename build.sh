#!/bin/bash

echo "Building StartEnvironment binary"
GOOS=linux GOARCH=amd64 go build -o main start/*.go

echo "Creating deployment package"
zip start-environment.zip main
rm main

echo "Building StopEnvironment binary"
GOOS=linux GOARCH=amd64 go build -o main stop/*.go

echo "Creating deployment package"
zip stop-environment.zip main
rm main