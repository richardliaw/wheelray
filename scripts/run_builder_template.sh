#!/bin/bash

if [[ $1 = "setup" ]]; then
    sudo pkill -9 apt-get || true
    sudo pkill -9 dpkg || true
    sudo dpkg --configure -a
    sudo apt-get -qq update
    sudo apt-get install -y python-pip
    pip install awscli -q --upgrade --user
    sudo apt-get install -y docker.io
    sudo kill -SIGUSR1 $(pidof dockerd) || true
    sudo service docker start
    sudo usermod -a -G docker ubuntu
else
    git clone https://github.com/ray-project/ray.git || true
    cd ray
    git config --add remote.origin.fetch "+refs/pull/*/head:refs/remotes/origin/pr/*"
    git fetch origin -q
    git checkout pr/<<<PR_NUMBER>>>
    cp /home/ubuntu/scripts/build-linux27.sh ./python/
    docker run --rm -w /ray -v `pwd`:/ray -t quay.io/xhochy/arrow_manylinux1_x86_64_base:latest /ray/python/build-linux27.sh
    ~/.local/bin/aws s3 sync .whl/ <<<BUCKET_URL>>>
fi
