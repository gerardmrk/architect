# ARCHITECT

## Anatomy

### Resource Block Declaration

```hcl
#
# [COMPONENT] "[PROVIDER]_[TYPE]" "[NAME]" {
#   ...[CONFIGURATION_&_ATTRIBUTES]
# }
#

resource "aws_instance" "main" {
  ami           = "ami-408c7f28"
  instance_type = "t1.micro"
}
```

## Scripts

### `validate`

- `--updated` (default): validates updated blueprints
- `--all`: validates all blueprints

### `format`

- `--updated` (default): formats updated blueprints
- `--all`: formats all blueprints

### `graph`

- generate dependency graphs for a specified group of resources

## Main Resources (_main)

iac state backend

iac state locker

credentials server

credentials database
