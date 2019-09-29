#!/usr/bin/env bash
set -ux

echo "[INFO] Setup centos"

sudo yum -y update
sudo yum install -y git
sudo yum install -y wget
sudo yum install -y jq
