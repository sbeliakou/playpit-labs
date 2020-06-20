#!/bin/bash

# Azure VM Fix
systemctl stop systemd-resolved
systemctl disable systemd-resolved
echo 'nameserver 8.8.8.8' > /etc/resolv.conf

apt-get update
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    git \
    gnupg-agent \
    software-properties-common
    
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

apt-get update
apt-get install -y docker-ce
systemctl enable --now docker

curl -L "https://github.com/docker/compose/releases/download/1.26.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod a+x /usr/local/bin/docker-compose

mkdir -p /opt/playpit/frontend/data/nginx /opt/playpit/backend

cat << END > /opt/playpit/frontend/data/nginx/nginx.conf
events {
    worker_connections  1024;
}

http {
  map \$http_upgrade \$connection_upgrade {
      default upgrade;
      '' close;
  }

  server {
    server_name ${SERVER_NAME};
    listen $(ifconfig eth0 | grep 'inet ' | awk '{print $2}'):8081;
    chunked_transfer_encoding on;

    location / {
      auth_basic "Registry realm";
      auth_basic_user_file /etc/nginx/conf.d/nginx.htpasswd;

      proxy_http_version 1.1;
      proxy_set_header   Upgrade \$http_upgrade;
      proxy_set_header   Connection \$connection_upgrade;

      proxy_set_header   Host              \$http_host;
      proxy_set_header   X-Real-IP         \$remote_addr;
      proxy_set_header   X-Forwarded-For   \$proxy_add_x_forwarded_for;
      proxy_set_header   X-Forwarded-Proto \$scheme;
      proxy_read_timeout 9000;

      proxy_pass         http://127.0.0.1:8081;
    }
    
    location ^~ /restart {
      auth_basic "Registry realm";
      auth_basic_user_file /etc/nginx/conf.d/nginx.htpasswd;
      proxy_pass         http://127.0.0.1:1080/;
    }
  }
}
END

docker run --rm sbeliakou/htpasswd ${username} '${password}' > /opt/playpit/frontend/data/nginx/nginx.htpasswd

cat << END > /opt/playpit/frontend/docker-compose.yaml
version: "2.3"

services:
  nginx:
    image: nginx:alpine
    volumes:
      - ./data/nginx/nginx.htpasswd:/etc/nginx/conf.d/nginx.htpasswd
      - ./data/nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./data/nginx/ssl:/etc/ssl:ro
    restart: always
    network_mode: host

  restart:
    image: sbeliakou/playpit-restart
    ports:
      - 127.0.0.1:1080:80
    volumes:
      - /opt/playpit:/opt/playpit
      - /var/run/docker.sock:/var/run/docker.sock 
    environment:
      NAME: ${NAME}
    restart: always
END

cd /opt/playpit/frontend/
docker-compose up -d

curl -s -o /opt/playpit/backend/docker-compose.yaml https://playpit-labs-assets.s3-eu-west-1.amazonaws.com/docker-compose/sbeliakou-${training}-cloud.yml
grep NAME /etc/environment || echo NAME="${NAME}" >> /etc/environment

cat << END > /opt/playpit/start.sh
#!/bin/bash

cd /opt/playpit/backend/

# cleanup
docker ps -qa --filter label=lab | xargs -r docker rm -f
docker volume ls --filter label=lab -q | xargs -r docker volume rm -f
docker network ls --filter label=lab -q | xargs -r docker network rm
docker-compose down --volumes

# update
docker-compose pull

# start
docker-compose up -d --renew-anon-volumes --remove-orphans
END

chmod a+x /opt/playpit/start.sh
NAME="${NAME}" /opt/playpit/start.sh