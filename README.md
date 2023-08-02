1. You can customize flask app by editing main.py from image folder
2. When ready you can build your own image by running command "docker build -t <name_of_image> ." from image directory
3. Push your image to AWS ECR (private registry) and note ECR registry URL and image URL
4. Put your registry URL and image URL to variables.tf file
5. run 'aws configure' and enter your secret credentials to allow your local environment to create resources in AWS
5. Go to docker_flask_app directory and run 'terraform init' and later 'terraform apply' to create resources in your AWS account
6. After apply command is finished copy URL from output in CLI; SSH key used by instance is generated by Terraform and saved in project directory
7. Paste URL to browser