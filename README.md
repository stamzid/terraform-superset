# terraform-superset

This README outlines the steps to run individual components in the specified order using Atmos. The components are: VPC, S3, IAM, ECR, Athena, Network, ECS, and Route53. This assume the user has AWS account setup and all the relevant environment variables created.

## Prerequisites
Before you begin, ensure you have the following:

Atmos CLI installed.
AWS CLI configured with the necessary permissions.
A .secretenv file with the required environment variables set.
Terraform installed.

## Secret File
Create a .secretenv file in your `atmos` directory with the following content (replace placeholders with actual values):

TF_VAR_admin_username=<ADMIN_USERNAME>
TF_VAR_admin_password=<ADMIN_PASSWORD>
TF_VAR_superset_secret_key=<SUPERSET_SECRET_KEY>
TF_VAR_hosted_zone_id=<HOSTED_ZONE_ID>

## Component Execution Order
All terraform commands must be run from `atmos` directory. It is the root terraform folder.
Then run each Terraform component in the following order:

### VPC
`AWS_PROFILE=<profile_name> atmos terraform apply vpc -s stamzid-ue1-dev`

### S3
`AWS_PROFILE=<profile_name> atmos terraform apply s3 -s stamzid-ue1-dev`

### IAM
`AWS_PROFILE=<profile_name> atmos terraform apply iam -s stamzid-ue1-dev`

### ECR
`AWS_PROFILE=<profile_name> atmos terraform apply ecr -s stamzid-ue1-dev`

### Docker Build Image

At this point, go to `superset` folder and export the following variables listed below:

AWS_ACCOUNT_ID=<your-aws-account-id>
AWS_REGION=<your-aws-region>
REPO_URL=<ECR repo url, this should be populated from the output of ECR terraform run>

Once the export is complete, simply run the bash file: `AWS_PROFILE=<profile_name> ./docker-build-push.sh`
This will build and push the image to ecr repor created with terraform.

### Athena
`AWS_PROFILE=<profile_name> atmos terraform apply athena -s stamzid-ue1-dev`

### Network
`AWS_PROFILE=<profile_name> atmos terraform apply network -s stamzid-ue1-dev`

### ECS
`AWS_PROFILE=<profile_name> atmos terraform apply ecs -s stamzid-ue1-dev`

### Route53
`AWS_PROFILE=<profile_name> atmos terraform apply route53 -s stamzid-ue1-dev`

## Notes
Ensure that each component is successfully applied before proceeding to the next one. Use the domain you generated as part of route53 run to access superset dashboard.
Verify that your AWS profile is correctly set up and has the necessary permissions to execute these commands.
The .secretenv file should be kept secure and not committed to version control systems.
This guide provides a structured approach to deploying your infrastructure components using Atmos and Terraform. Adjust the commands according to your specific AWS configuration and environment setup.
An sql script with some queries are saved under sql folder. Data folder contains a public csv file that is used for athena query testing.
Individual plan files for each terraform component can be found under `atmos/plans` directory.