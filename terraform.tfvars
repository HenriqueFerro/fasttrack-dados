# Copyright (c) 2019, 2020 Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# provider identity parameters
user_id="ocid1.user.oc1..aaaaaaaa5ki2ncx3futq4ryqpka2fmswdnbd5ulu6gs5qc3hx366pvz7fcga"
api_fingerprint="a7:a0:07:3c:42:95:4e:8f:db:14:77:ce:1e:32:a9:e7"
tenancy_id="ocid1.tenancy.oc1..aaaaaaaa47bheytwsessxhugyxxybcjxn2mciwpph7t6bo3ruulncwkwfsiq"
region="sa-saopaulo-1"

api_private_key_path= "/Users/henrique/Developer/oci/ssh-key/oracleidentitycloudservice_henrique.oci.teste-07-28-21-32.pem"

# general oci parameters
compartment_id = "ocid1.compartment.oc1..aaaaaaaaz57gpr45knoo6aq4s6xy5ffwxoqprjuuzhvycb4xa57hrdj3nxea"
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