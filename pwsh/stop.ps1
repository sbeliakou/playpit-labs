if ( (git rev-parse --abbrev-ref HEAD) -eq "master") {
  git reset --hard HEAD | Out-Null
  git pull -f | Out-Null
}

Write-Output "Checking Requirements:"
if (Get-Command "docker.exe" 2> $null) { 
  Write-Output "docker              ..  ok"
}
else {
  Write-Output "docker              ..  FAILED (can't find in PATH)"
  exit 1
}

if (Get-Process "Docker Desktop" -ErrorAction SilentlyContinue) {
  Write-Output "docker is running   ..  ok"
}
else {
  Write-Output "docker is running   ..  FAILED (is docker running?)"
  exit 1
}

if (Get-Command "docker-compose.exe" 2> $null) { 
  Write-Output "docker-compose      ..  ok"
}
else {
  Write-Output "docker-compose      ..  FAILED (can't find in PATH)"
  exit 1
}

## Removing previous stack, if it is
docker ps -qa --filter label=lab | ForEach-Object { docker rm -f $_ }
docker volume ls --filter label=lab -q | ForEach-Object { docker volume rm -f $_ }
docker network ls --filter label=lab -q | ForEach-Object { docker network rm $_ }
