# VPC Module

This module creates a VPC (plus related resources) that caters to non-complex scenarios, yet while following best-practices that makes the VPC robust and future-proofed.

The setup is ideal for most usecases if you're not a large-sized multinational business (in which case you probably shouldn't be using this anyways), i.e. serious side-projects, startup-scenarios, etc..

## Restrictions/Limitations

- The module does not account for VPC-peering or VPN-connections to non-AWS networks, so choose a CIDR range accordingly (VPCs with overlapping CIDRs cannot be peered).

- The region (inferred from the provider block of the calling template) must have has at least 3 availability zones (some regions only have 2 AZs).

## Resources & Services

