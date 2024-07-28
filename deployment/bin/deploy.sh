#!/bin/bash

set -e

PROJECT_DIR="/var/www/html/demo"

# make dir if not exists (first deploy)
mkdir -p $PROJECT_DIR

cd $PROJECT_DIR

git config --global --add safe.directory $PROJECT_DIR

# the project has not been cloned yet (first deploy)
if [ ! -d $PROJECT_DIR"/.git" ]; then
  GIT_SSH_COMMAND='ssh -i /home/mohammad/.ssh/id_rsa -o IdentitiesOnly=yes' git clone git@github.com:MohammadAlhallaq/infra-demo.git
else
  GIT_SSH_COMMAND='ssh -i /home/mohammad/.ssh/id_rsa -o IdentitiesOnly=yes' git pull
fi

