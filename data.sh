#!/bin/bash
sudo yum update -y
sudo yum install -y docker
sudo service docker start
aws ecr get-login-password --region ${region} | docker login --username AWS --password-stdin ${ecr_registry}
docker run -it -e PORT=${port} -p ${port}:${port} -d --name flask_app ${image_name}