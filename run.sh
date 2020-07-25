#!/bin/bash

echo "Script name: run centos 7"
echo "*************************"

docker rm -f centos7

docker run \
	-dit \
	--name=centos7 \
	--hostname=centos \
	--privileged \
	-v /sys/fs/cgroup:/sys/fs/cgroup:ro \
	-v /tmp/$(mktemp -d):/run \
	c7-systemd:dev
