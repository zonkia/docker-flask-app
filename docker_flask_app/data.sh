#!/bin/bash
sudo yum update -y
sudo yum install -y docker
sudo service docker start
docker run -it -e PORT=${port} -p ${port}:${port} -d ${image_name}