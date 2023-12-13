## Terraform Design

I chose to follow atmos / cloudposse terraform moduler format because it creates a moduler view of the infra where base modules are re-usable. All the values are defined upfront so it's easier to maintain.

## Choice of Deployment Environment

For this exercise, I chose ECS Fargate just becuase the overhead is lot less than using EKS. It is also cheaper.

## Superset
I decided to build another layer on top of official superset image. This way I could install PyAthena and configure superset to use Athena as DB. There is also consul service running, that can be used when more services are added to this cluster and then consul can be the service mesh for the cluster.