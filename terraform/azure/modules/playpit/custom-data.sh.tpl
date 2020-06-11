#!/bin/bash

apt-get update
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    git \
    gnupg-agent \
    software-properties-common
    
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

apt-get update
apt-get install -y docker-ce
systemctl enable --now docker

curl -L "https://github.com/docker/compose/releases/download/1.26.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod a+x /usr/local/bin/docker-compose


mkdir -p /opt/oauth

cat << END > /opt/oauth/nginx.conf
events {
    worker_connections  1024;
}

http {

  upstream playpit-stand {
    server 127.0.0.1:8081;
  }

  map \$http_upgrade \$connection_upgrade {
      default upgrade;
      '' close;
  }

  server {
    listen $(ifconfig eth0 | grep 'inet ' | awk '{print $2}'):8081;

    # disable any limits to avoid HTTP 413 for large image uploads
    client_max_body_size 0;

    # required to avoid HTTP 411: see Issue #1486 (https://github.com/moby/moby/issues/1486)
    chunked_transfer_encoding on;

    location / {
      auth_basic "Registry realm";
      auth_basic_user_file /etc/nginx/conf.d/nginx.htpasswd;

      proxy_pass                          http://playpit-stand;

      proxy_http_version 1.1;
      proxy_set_header Upgrade \$http_upgrade;
      proxy_set_header Connection \$connection_upgrade;

      proxy_set_header  Host              \$http_host;   # required for docker client's sake
      proxy_set_header  X-Real-IP         \$remote_addr; # pass on real client's IP
      proxy_set_header  X-Forwarded-For   \$proxy_add_x_forwarded_for;
      proxy_set_header  X-Forwarded-Proto \$scheme;
      proxy_read_timeout                  900;
    }
  }
}
END

docker run --rm \
  --entrypoint htpasswd \
  registry:2 -Bbn ${username} ${password} > /opt/oauth/nginx.htpasswd

docker run -d --restart=always \
  -v /opt/oauth:/etc/nginx/conf.d \
  -v /opt/oauth/nginx.conf:/etc/nginx/nginx.conf:ro \
  --network=host \
  nginx:alpine

mkdir -p /opt/playpit/
curl -s -o /opt/playpit/docker-compose.yaml https://playpit-labs-assets.s3-eu-west-1.amazonaws.com/docker-compose/sbeliakou-${training}-cloud.yml

# cleanup
docker ps -qa --filter label=lab | xargs -r docker rm -f
docker volume ls --filter label=lab -q | xargs -r docker volume rm -f
docker network ls --filter label=lab -q | xargs -r docker network rm

cd /opt/playpit/

USERNAME="${fullname}" docker-compose pull
USERNAME="${fullname}" docker-compose up -d --renew-anon-volumes --remove-orphans
