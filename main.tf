# Copyright (c) 2019, 2021, Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

# Version requirements

terraform {
  required_version = ">= 0.13"
  required_providers {
    oci = {
      source  = "hashicorp/oci"
      version = "4.37.0"
    }
  }
}

# Modules

module "vcn" {
  source  = "oracle-terraform-modules/vcn/oci"
  version = "2.3.0"

  # general oci parameters
  compartment_id = var.compartment_id
  label_prefix   = var.label_prefix
  tags           = var.tags
  region         = var.region

  # vcn parameters
  create_drg               = var.create_drg               # boolean: true or false
  internet_gateway_enabled = var.internet_gateway_enabled # boolean: true or false
  lockdown_default_seclist = var.lockdown_default_seclist # boolean: true or false
  nat_gateway_enabled      = var.nat_gateway_enabled      # boolean: true or false
  service_gateway_enabled  = var.service_gateway_enabled  # boolean: true or false
  vcn_cidr                 = var.vcn_cidr                 # VCN CIDR
  vcn_dns_label            = var.vcn_dns_label
  vcn_name                 = var.vcn_name

  # gateways parameters
  drg_display_name = var.drg_display_name
}

# Resources

resource "oci_core_security_list" "private-security-list" {

  # Required
  compartment_id = var.compartment_id
  vcn_id         = module.vcn.vcn_id

  # Optional
  display_name = "security-list-for-private-subnet"

  egress_security_rules {
    stateless        = false
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
  }

  ingress_security_rules {
    stateless   = false
    source      = "10.0.0.0/16"
    source_type = "CIDR_BLOCK"
    # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml TCP is 6
    protocol = "6"
    tcp_options {
      min = 22
      max = 22
    }
  }
  ingress_security_rules {
    stateless   = false
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml ICMP is 1  
    protocol = "1"
    # For ICMP type and code see: https://www.iana.org/assignments/icmp-parameters/icmp-parameters.xhtml
    icmp_options {
      type = 3
      code = 4
    }
  }

  ingress_security_rules {
    stateless   = false
    source      = "10.0.0.0/16"
    source_type = "CIDR_BLOCK"
    # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml ICMP is 1  
    protocol = "1"
    # For ICMP type and code see: https://www.iana.org/assignments/icmp-parameters/icmp-parameters.xhtml
    icmp_options {
      type = 3
    }
  }
}

resource "oci_core_subnet" "vcn-private-subnet" {

  # Required
  compartment_id = var.compartment_id
  vcn_id         = module.vcn.vcn_id
  cidr_block     = var.sub_pub_cidr

  # Optional
  # Caution: For the route table id, use module.vcn.nat_route_id.
  # Do not use module.vcn.nat_gateway_id, because it is the OCID for the gateway and not the route table.
  route_table_id    = module.vcn.nat_route_id
  security_list_ids = [oci_core_security_list.private-security-list.id]
  display_name      = "private-subnet"
}

resource "oci_core_security_list" "public-security-list" {

  # Required
  compartment_id = var.compartment_id
  vcn_id         = module.vcn.vcn_id

  # Optional
  display_name = "security-list-for-public-subnet"

  egress_security_rules {
    stateless        = false
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
  }

  ingress_security_rules {
    stateless   = false
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml TCP is 6
    protocol = "6"
    tcp_options {
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    stateless   = false
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml ICMP is 1  
    protocol = "1"

    # For ICMP type and code see: https://www.iana.org/assignments/icmp-parameters/icmp-parameters.xhtml
    icmp_options {
      type = 3
      code = 4
    }
  }

  ingress_security_rules {
    stateless   = false
    source      = "10.0.0.0/16"
    source_type = "CIDR_BLOCK"
    # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml ICMP is 1  
    protocol = "1"

    # For ICMP type and code see: https://www.iana.org/assignments/icmp-parameters/icmp-parameters.xhtml
    icmp_options {
      type = 3
    }
  }
}

resource "oci_core_subnet" "vcn-public-subnet" {

  # Required
  compartment_id = var.compartment_id
  vcn_id         = module.vcn.vcn_id
  cidr_block     = "10.0.0.0/24"

  # Optional
  route_table_id    = module.vcn.ig_route_id
  security_list_ids = [oci_core_security_list.public-security-list.id]
  display_name      = "public-subnet"
}

resource "oci_objectstorage_bucket" "dataflow-logs" {
    #Required
    compartment_id = var.compartment_id
    namespace = var.bucket_namespace
    name = "dataflow-logs"
}

resource "oci_objectstorage_bucket" "dataflow-warehouse" {
    #Required
    compartment_id = var.compartment_id
    namespace = var.bucket_namespace
    name = "dataflow-warehouse"
}

resource "oci_objectstorage_bucket" "app" {
    #Required
    compartment_id = var.compartment_id
    namespace = var.bucket_namespace
    name = "app"
}

# Outputs

output "module_vcn_ids" {
  description = "vcn and gateways information"
  value = {
    drg_id                       = module.vcn.drg_id
    internet_gateway_id          = module.vcn.internet_gateway_id
    internet_gateway_route_id    = module.vcn.ig_route_id
    nat_gateway_id               = module.vcn.nat_gateway_id
    nat_gateway_route_id         = module.vcn.nat_route_id
    service_gateway_id           = module.vcn.service_gateway_id
    vcn_dns_label                = module.vcn.vcn_all_attributes.dns_label
    vcn_default_security_list_id = module.vcn.vcn_all_attributes.default_security_list_id
    vcn_default_route_table_id   = module.vcn.vcn_all_attributes.default_route_table_id
    vcn_default_dhcp_options_id  = module.vcn.vcn_all_attributes.default_dhcp_options_id
    vcn_id                       = module.vcn.vcn_id
  }
}

output "private-security-infos" {
  description = "private security list informations"
  value = {
    private-subnet-name        = oci_core_subnet.vcn-private-subnet.display_name
    private-subnet-OCID        = oci_core_subnet.vcn-private-subnet.id
    private_security_list_name = oci_core_security_list.private-security-list.display_name
    private_security_list_id   = oci_core_security_list.private-security-list.id
  }
}

output "public-security-infos" {
  value = {
    public-subnet-name        = oci_core_subnet.vcn-public-subnet.display_name
    public-subnet-OCID        = oci_core_subnet.vcn-public-subnet.id
    public_security_list_name = oci_core_security_list.public-security-list.display_name
    public_security_list_id   = oci_core_security_list.public-security-list.id
  }
}
