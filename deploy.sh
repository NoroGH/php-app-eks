#!/bin/zsh

docker container rm nginx_cont php_cont --force

docker rmi nginx_image:$(git rev-parse HEAD) php_image:$(git rev-parse HEAD)

docker build -t nginx_image:$(git rev-parse HEAD) --target stage-nginx .

docker tag nginx_image:$(git rev-parse HEAD) public.ecr.aws/y6q8o0k2/nginx_image:$(git rev-parse HEAD)

docker push public.ecr.aws/y6q8o0k2/nginx_image:$(git rev-parse HEAD)

docker build -t php_image:$(git rev-parse HEAD) --target stage-php .

docker tag php_image:$(git rev-parse HEAD) public.ecr.aws/y6q8o0k2/php_image:$(git rev-parse HEAD)

docker push public.ecr.aws/y6q8o0k2/php_image:$(git rev-parse HEAD)

docker pull public.ecr.aws/y6q8o0k2/php_image:$(git rev-parse HEAD) 

docker container run -itd --name php_cont --network br02 -p 9000:9000 php_image:$(git rev-parse HEAD)

docker pull public.ecr.aws/y6q8o0k2/nginx_image:$(git rev-parse HEAD) 

docker container run -itd --name nginx_cont --network br02 -p 80:80 nginx_image:$(git rev-parse HEAD)