# Copyright (c) 2019, 2020 Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# provider identity parameters
user_id=""
api_fingerprint=""
tenancy_id=""
region="sa-saopaulo-1"

api_private_key_path= ""

# general oci parameters
compartment_id = ""
label_prefix = "tst"

# vcn parameters
create_drg = false
internet_gateway_enabled = true
nat_gateway_enabled = true
service_gateway_enabled = true
vcn_cidr = "10.0.0.0/16"
vcn_dns_label = "vcn"
vcn_name = "vcn"

# private subnet parameters
sub_pvt_cidr = "10.0.1.0/24"
sub_pub_cidr = "10.0.1.0/24"

# bucket parameters
bucket_namespace = "grql6ky0hxgc"

tags = {
  environment = "tst"
  lob = "fasttrack"
}
