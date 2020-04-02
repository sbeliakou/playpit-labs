# Playpit Labs: Local Hands-on Playground

**Playpit-Labs** is a learner-centric Training Platform which enables to facilitate a wide range of learning tasks (investigation, troubleshooting, development) via interactive module system. 

Based on a hands-on experience, the Platform delivers scenario-related approach with instant feedback. So, the user can easily navigate his training path - learn, practice, instantly check the results and track the progress in the personal report in the course of a chosen technology or a tool (currently available courses - __Docker__ and __Kubernetes__).

The Platform can be used either in a face-to-face training, an instructor-led training, a blended learning, or just a self-paced training to address multi-purpose demands.

Design of the course is aimed to provide a wide scope of scenarios to cover all the competency levels starting from the beginner and up to advance during a step-by-step learning process. **Playpit-Labs** is a kind of a virtual campus, where everyone can anytime and anywhere access the training materials and interact. 

#### Check it out and try!

### Main Features:
- In-browser terminal window
- Integrated web browsing facility
- Easy navigation between tasks/scenarios
- Instant feedback with scoring results
- Tracking overall progress
- Hundreds of development and troubleshooting scenarios
- Changeable environment for various use cases
- Full support of useful documentation

### Architecture Specifics:
- Docker-based (systemd) containers (Linux inside!!!)
- Pre-baked configuration (as per lab purposes)
- Fast and easy rolling out

## System Requirements:
Please ensure that your local station meets the following requirements before using current product:

- [Docker](https://docs.docker.com/install/) (19+) or [Docker Desktop](https://www.docker.com/products/docker-desktop) (2.2+) installed 
- [docker-compose](https://docs.docker.com/compose/install/) (1.25+) installed
- Use [Chrome](https://www.google.com/chrome/?brand=CHBD&gclid=EAIaIQobChMIkqeL5LeB6AIVDPlRCh0AhA73EAAYASABEgKGvfD_BwE&gclsrc=aw.ds)/[Chromium](https://www.chromium.org/getting-involved/download-chromium) Browser for stable work

## Usage:

Here's a list of commands which bring this stand up and terminate local infrastructure.

**Linux/MacOS Bash**:
```sh
bash/start                 ## Getting Help
bash/start docker          ## starting Docker Lab
bash/start kubernetes      ## starting Kubernetes Lab
bash/stop                  ## Tearing it all down
```

**Windows PowerShell**:

Open powershell console as Administrator and execute:

```powershell
Set-ExecutionPolicy Unrestricted  ## Getting an ability to execute pwsh scripts
```

The next step is:

```powershell
pwsh\start.ps1             ## Getting Help
pwsh\start.ps1 docker      ## starting Docker Lab
pwsh\start.ps1 kubernetes  ## starting Kubernetes Lab
pwsh\stop.ps1              ## Tearing it all down
```

## Lab URLs

Lab stand is available by the following addresses:
- http://lab.playpit.net:8081/
- http://localhost:8081/


## Available Trainings and Scopes
- **Kubernetes** (pods, deployments, services, ingresses, volumes, configMaps and secretes, helm, etc)
- **Docker** (images, containers, volumes, networks, docker-compose, namespaces and cgroups, daemon configuration, etc)

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
