## Rolling out Playpit Environment in Azure Cloud

### Prerequisites

Make sure you have following variables set in your Environment:

```
export ARM_CLIENT_ID=..
export ARM_TENANT_ID=...
export ARM_CLIENT_SECRET=...
export ARM_SUBSCRIPTION_ID=...
```

### Creating a stack

1. Go to `docker` or `kubernetes` folder
2. Set your Name in `main.tf` file like here:

```
module "playpit" {
  source = "../modules/playpit"
  training = "docker"
  vm_size = "Standard_F4s_v2"
   
  fullname = "Siarhei Beliakou"
  shortname = "sbeliakou"
}
...
```

### Run it with Terraform:

```
## Creating a stack
$ terraform init
$ terraform plan
$ terraform apply

## Checking createntials
$ terraform show | tail -3
credentials = "sbeliakou / password_here"
server_name = "sbeliakou-kubernetes-playpit.northeurope.cloudapp.azure.com"
service_name = "http://sbeliakou-kubernetes-playpit.northeurope.cloudapp.azure.com:8081/"

## Destroying environment
$ terraform destroy
```


## Using Platform:

1. Find service name and credentials, like this one:
```
## Checking createntials
$ terraform show | tail -3
credentials = "sbeliakou / password_here"
server_name = "sbeliakou-kubernetes-playpit.northeurope.cloudapp.azure.com"
service_name = "http://sbeliakou-kubernetes-playpit.northeurope.cloudapp.azure.com:8081/"
```

2. Browse `service_name` url, profide credentials
3. For the metter of restar the stand, please follow `/restart` context path in service url.