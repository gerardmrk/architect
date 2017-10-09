# ARCHITECT

Builds
- a complete VPC on AWS, with 
  - 3 private and 3 public subnets,
  - 2 route tables, 1 NAT gateway,
  - 1 EIP,
  - 1 internet gateway,
  - 2 security groups
- a Vault cluster
  - using ACG, ELB, and EC2 micro instances
  - an S3 backend
- a Terraform remote state backend with
  - an S3 state storage
  - and HA enabled using remote state locks with AWS DynamoDB

## Scripts

### `validate`

- `--updated` (default): validates updated blueprints
- `--all`: validates all blueprints

### `format`

- `--updated` (default): formats updated blueprints
- `--all`: formats all blueprints

### `graph`

- generate dependency graphs for a specified group of resources

## Main Resources & Services (base)

iac state backend

iac state lock

credentials server

credentials database
