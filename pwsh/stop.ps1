if ( (git rev-parse --abbrev-ref HEAD) -eq "master") {
  git reset --hard HEAD | Out-Null
  git pull -f | Out-Null
}

## Removing previous stack, if it is
docker ps -q --filter label=lab | ForEach-Object { docker rm -f $_ }
docker volume ls --filter label=lab -q | ForEach-Object { docker volume rm -f $_ }
docker network ls --filter label=lab -q | ForEach-Object { docker network rm $_ }