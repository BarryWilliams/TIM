#!/bin/sh

docker build . -t barrywilliams/k8s-ruby-sample-app


#local run
# docker run -p 4567:4567 barrywilliams/k8s-ruby-sample-app