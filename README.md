# Playpit Labs: Local Hands-on Playground

### Main Features:
- In-browser terminal window
- Integrated browser window facility
- Easy navigation between tasks/scenarios
- Instant feedback with scoring results
- Tracking overall progress
- Hundreads of scenarios of development and troubleshooting
- Changeable environment for various use cases
- Full of useful documentation

### Architecture Specifics:
- Docker-based (systemd) containers
- Pre-baked configuration (as per lab purpose)
- Fast and easy rolling out

## System Requirements:
Please ensure that your local station supports those requirements before using current product:

- [Docker](https://docs.docker.com/install/) (19+) or [Docker Desktop](https://www.docker.com/products/docker-desktop) (2.2+) installed 
- [docker-compose](https://docs.docker.com/compose/install/) (1.25+) installed
- Use [Chrome](https://www.google.com/chrome/?brand=CHBD&gclid=EAIaIQobChMIkqeL5LeB6AIVDPlRCh0AhA73EAAYASABEgKGvfD_BwE&gclsrc=aw.ds)/[Chromium](https://www.chromium.org/getting-involved/download-chromium) Browser for stable work

## Usage:

Here's a list of commands which brings this stand up and terminate local infrastructure.

```sh
./start <training_name>
./stop
```

More Details:
```sh
## Getting Help
./start 

## start Docker Lab
./start docker

## start Kubernetes Lab
./start kubernetes

## Tearing it All Down
./stop
```

## Lab URL

Lab stand available by following urls:
- http://lab.playpit.net:8081/
- http://localhost:8081/


## Available Trainings and Scopes
- **kubernetes** (pods, deployments, services, ingress, volumes, configMaps and secretes, helm, etc)
- **docker** (images, containers, volumes, networks, docker-compose, namespaces and cgroups, daemon configuration, etc)

## Screen Shots
![](https://playpit-labs-assets.s3-eu-west-1.amazonaws.com/screenshots/login-window.png)
![](https://playpit-labs-assets.s3-eu-west-1.amazonaws.com/screenshots/module-start.png)
![](https://playpit-labs-assets.s3-eu-west-1.amazonaws.com/screenshots/loading.png)
![](https://playpit-labs-assets.s3-eu-west-1.amazonaws.com/screenshots/success-window.png)
![](https://playpit-labs-assets.s3-eu-west-1.amazonaws.com/screenshots/failure-window.png)
![](https://playpit-labs-assets.s3-eu-west-1.amazonaws.com/screenshots/sample-quiz-1.png)
![](https://playpit-labs-assets.s3-eu-west-1.amazonaws.com/screenshots/allgood.png)
![](https://playpit-labs-assets.s3-eu-west-1.amazonaws.com/screenshots/progress.png)
![](https://playpit-labs-assets.s3-eu-west-1.amazonaws.com/screenshots/closed.png)
