1. You can customize flask app by editing main.py from image folder
2. When ready you can build your own image by running command "docker build -t <name_of_image> ."
3. You can push your image to Docker Hub or AWS ECR to be later used by Terraform deployment
4. Go to docker_flask_app directory and run terraform apply to create resources in your AWS account
5. After apply command is finished copy URL from output in CLI
6. Paste URL to browser