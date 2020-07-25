#!/bin/bash

echo "Script name: build centos 7"
echo "***************************"

docker build --rm --tag c7-systemd:dev .
