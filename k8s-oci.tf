
locals {
  master_lb_ip      = "${var.master_oci_lb_enabled == "true" ? element(concat(flatten(module.k8smaster-public-lb.ip_addresses), list("")), 0) : "127.0.0.1"}"
  master_lb_address = "${format("https://%s:%s", local.master_lb_ip, var.master_oci_lb_enabled == "true" ? "443" : "6443")}"
}

### CA and Cluster Certificates

module "k8s-tls" {
  source                 = "./tls/"
  api_server_private_key = "${var.api_server_private_key}"
  api_server_cert        = "${var.api_server_cert}"
  ca_cert                = "${var.ca_cert}"
  ca_key                 = "${var.ca_key}"
  api_server_admin_token = "${var.api_server_admin_token}"
  master_lb_public_ip    = "${local.master_lb_ip}"
  master_ips             = "${concat(module.instances-k8smaster-ad1.public_ips,module.instances-k8smaster-ad2.public_ips,module.instances-k8smaster-ad3.public_ips )}"
  ssh_private_key        = "${var.ssh_private_key}"
  ssh_public_key_openssh = "${var.ssh_public_key_openssh}"
}

### Virtual Cloud Network

module "vcn" {
  source                                  = "./network/vcn"
  compartment_ocid                        = "${var.compartment_ocid}"
  label_prefix                            = "${var.label_prefix}"
  tenancy_ocid                            = "${var.tenancy_ocid}"
  vcn_dns_name                            = "${var.vcn_dns_name}"
  additional_etcd_security_lists_ids      = "${var.additional_etcd_security_lists_ids}"
  additional_k8smaster_security_lists_ids = "${var.additional_k8s_master_security_lists_ids}"
  additional_k8sworker_security_lists_ids = "${var.additional_k8s_worker_security_lists_ids}"
  additional_public_security_lists_ids    = "${var.additional_public_security_lists_ids}"
  control_plane_subnet_access             = "${var.control_plane_subnet_access}"
  etcd_ssh_ingress                        = "${var.etcd_ssh_ingress}"
  etcd_cluster_ingress                    = "${var.etcd_cluster_ingress}"
  master_ssh_ingress                      = "${var.master_ssh_ingress}"
  master_https_ingress                    = "${var.master_https_ingress}"
  network_cidrs                           = "${var.network_cidrs}"
  public_subnet_ssh_ingress               = "${var.public_subnet_ssh_ingress}"
  public_subnet_http_ingress              = "${var.public_subnet_http_ingress}"
  public_subnet_https_ingress             = "${var.public_subnet_https_ingress}"
  nat_instance_oracle_linux_image_name    = "${var.nat_ol_image_name}"
  nat_instance_shape                      = "${var.natInstanceShape}"
  nat_instance_ad1_enabled                = "${var.nat_instance_ad1_enabled}"
  nat_instance_ad2_enabled                = "${var.nat_instance_ad2_enabled}"
  nat_instance_ad3_enabled                = "${var.nat_instance_ad3_enabled}"
  nat_instance_ssh_public_key_openssh     = "${module.k8s-tls.ssh_public_key_openssh}"
  dedicated_nat_subnets                   = "${var.dedicated_nat_subnets}"
  worker_ssh_ingress                      = "${var.worker_ssh_ingress}"
  worker_nodeport_ingress                 = "${var.worker_nodeport_ingress}"
  external_icmp_ingress                   = "${var.external_icmp_ingress}"
  internal_icmp_ingress                   = "${var.internal_icmp_ingress}"
}

### Compute Instance(s)

module "instances-etcd-ad1" {
  source                      = "./instances/etcd"
  count                       = "${var.etcdAd1Count}"
  availability_domain         = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[0],"name")}"
  compartment_ocid            = "${var.compartment_ocid}"
  control_plane_subnet_access = "${var.control_plane_subnet_access}"
  display_name_prefix         = "etcd-ad1"
  domain_name                 = "${var.domain_name}"
  hostname_label_prefix       = "etcd-ad1"
  oracle_linux_image_name     = "${var.etcd_ol_image_name}"
  label_prefix                = "${var.label_prefix}"
  shape                       = "${var.etcdShape}"
  ssh_public_key_openssh      = "${module.k8s-tls.ssh_public_key_openssh}"
  network_cidrs               = "${var.network_cidrs}"
  subnet_id                   = "${module.vcn.etcd_subnet_ad1_id}"
  subnet_name                 = "etcdSubnetAD1"
  tenancy_ocid                = "${var.compartment_ocid}"
  etcd_iscsi_volume_create    = "${var.etcd_iscsi_volume_create}"
  etcd_iscsi_volume_size      = "${var.etcd_iscsi_volume_size}"
  assign_private_ip           = "${var.etcd_maintain_private_ip == "true" ? "true": "false"}"
}

module "instances-etcd-ad2" {
  source                      = "./instances/etcd"
  count                       = "${var.etcdAd2Count}"
  availability_domain         = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[1],"name")}"
  compartment_ocid            = "${var.compartment_ocid}"
  control_plane_subnet_access = "${var.control_plane_subnet_access}"
  display_name_prefix         = "etcd-ad2"
  domain_name                 = "${var.domain_name}"
  hostname_label_prefix       = "etcd-ad2"
  oracle_linux_image_name     = "${var.etcd_ol_image_name}"
  label_prefix                = "${var.label_prefix}"
  shape                       = "${var.etcdShape}"
  ssh_public_key_openssh      = "${module.k8s-tls.ssh_public_key_openssh}"
  network_cidrs               = "${var.network_cidrs}"
  subnet_id                   = "${module.vcn.etcd_subnet_ad2_id}"
  subnet_name                 = "etcdSubnetAD2"
  tenancy_ocid                = "${var.compartment_ocid}"
  etcd_iscsi_volume_create    = "${var.etcd_iscsi_volume_create}"
  etcd_iscsi_volume_size      = "${var.etcd_iscsi_volume_size}"
  assign_private_ip           = "${var.etcd_maintain_private_ip == "true" ? "true": "false"}"
}

module "instances-etcd-ad3" {
  source                      = "./instances/etcd"
  count                       = "${var.etcdAd3Count}"
  availability_domain         = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[2],"name")}"
  compartment_ocid            = "${var.compartment_ocid}"
  control_plane_subnet_access = "${var.control_plane_subnet_access}"
  display_name_prefix         = "etcd-ad3"
  domain_name                 = "${var.domain_name}"
  hostname_label_prefix       = "etcd-ad3"
  oracle_linux_image_name     = "${var.etcd_ol_image_name}"
  label_prefix                = "${var.label_prefix}"
  shape                       = "${var.etcdShape}"
  ssh_public_key_openssh      = "${module.k8s-tls.ssh_public_key_openssh}"
  network_cidrs               = "${var.network_cidrs}"
  subnet_id                   = "${module.vcn.etcd_subnet_ad3_id}"
  subnet_name                 = "etcdSubnetAD3"
  tenancy_ocid                = "${var.compartment_ocid}"
  etcd_iscsi_volume_create    = "${var.etcd_iscsi_volume_create}"
  etcd_iscsi_volume_size      = "${var.etcd_iscsi_volume_size}"
  assign_private_ip           = "${var.etcd_maintain_private_ip == "true" ? "true": "false"}"
}

module "instances-k8smaster-ad1" {
  source                      = "./instances/k8smaster"
  count                       = "${var.k8sMasterAd1Count}"
  availability_domain         = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[0],"name")}"
  compartment_ocid            = "${var.compartment_ocid}"
  control_plane_subnet_access = "${var.control_plane_subnet_access}"
  display_name_prefix         = "k8s-master-ad1"
  domain_name                 = "${var.domain_name}"
  hostname_label_prefix       = "k8s-master-ad1"
  oracle_linux_image_name     = "${var.master_ol_image_name}"
  label_prefix                = "${var.label_prefix}"
  shape                       = "${var.k8sMasterShape}"
  ssh_private_key             = "${module.k8s-tls.ssh_private_key}"
  ssh_public_key_openssh      = "${module.k8s-tls.ssh_public_key_openssh}"
  network_cidrs               = "${var.network_cidrs}"
  subnet_id                   = "${module.vcn.k8smaster_subnet_ad1_id}"
  subnet_name                 = "masterSubnetAD1"
  tenancy_ocid                = "${var.compartment_ocid}"
  assign_private_ip           = "${var.master_maintain_private_ip}"
}

module "instances-k8smaster-ad2" {
  source                      = "./instances/k8smaster"
  count                       = "${var.k8sMasterAd2Count}"
  availability_domain         = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[1],"name")}"
  compartment_ocid            = "${var.compartment_ocid}"
  control_plane_subnet_access = "${var.control_plane_subnet_access}"
  display_name_prefix         = "k8s-master-ad2"
  domain_name                 = "${var.domain_name}"
  hostname_label_prefix       = "k8s-master-ad2"
  oracle_linux_image_name     = "${var.master_ol_image_name}"
  label_prefix                = "${var.label_prefix}"
  shape                       = "${var.k8sMasterShape}"
  ssh_private_key             = "${module.k8s-tls.ssh_private_key}"
  ssh_public_key_openssh      = "${module.k8s-tls.ssh_public_key_openssh}"
  network_cidrs               = "${var.network_cidrs}"
  subnet_id                   = "${module.vcn.k8smaster_subnet_ad2_id}"
  subnet_name                 = "masterSubnetAD2"
  tenancy_ocid                = "${var.compartment_ocid}"
  assign_private_ip           = "${var.master_maintain_private_ip}"
}

module "instances-k8smaster-ad3" {
  source                      = "./instances/k8smaster"
  count                       = "${var.k8sMasterAd3Count}"
  availability_domain         = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[2],"name")}"
  compartment_ocid            = "${var.compartment_ocid}"
  control_plane_subnet_access = "${var.control_plane_subnet_access}"
  display_name_prefix         = "k8s-master-ad3"
  domain_name                 = "${var.domain_name}"
  hostname_label_prefix       = "k8s-master-ad3"
  oracle_linux_image_name     = "${var.master_ol_image_name}"
  label_prefix                = "${var.label_prefix}"
  shape                       = "${var.k8sMasterShape}"
  ssh_private_key             = "${module.k8s-tls.ssh_private_key}"
  ssh_public_key_openssh      = "${module.k8s-tls.ssh_public_key_openssh}"
  network_cidrs               = "${var.network_cidrs}"
  subnet_id                   = "${module.vcn.k8smaster_subnet_ad3_id}"
  subnet_name                 = "masterSubnetAD3"
  tenancy_ocid                = "${var.compartment_ocid}"
  assign_private_ip           = "${var.master_maintain_private_ip}"
}

module "instances-k8sworker-ad1" {
  source                      = "./instances/k8sworker"
  count                       = "${var.k8sWorkerAd1Count}"
  availability_domain         = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[0],"name")}"
  compartment_ocid            = "${var.compartment_ocid}"
  display_name_prefix         = "k8s-worker-ad1"
  domain_name                 = "${var.domain_name}"
  hostname_label_prefix       = "k8s-worker-ad1"
  oracle_linux_image_name     = "${var.worker_ol_image_name}"
  label_prefix                = "${var.label_prefix}"
  region                      = "${var.region}"
  shape                       = "${var.k8sWorkerShape}"
  ssh_private_key             = "${module.k8s-tls.ssh_private_key}"
  ssh_public_key_openssh      = "${module.k8s-tls.ssh_public_key_openssh}"
  subnet_id                   = "${module.vcn.k8worker_subnet_ad1_id}"
  tenancy_ocid                = "${var.compartment_ocid}"
  worker_iscsi_volume_create  = "${var.worker_iscsi_volume_create}"
  worker_iscsi_volume_size    = "${var.worker_iscsi_volume_size}"
  worker_iscsi_volume_mount   = "${var.worker_iscsi_volume_mount}"
}

module "instances-k8sworker-ad2" {
  source                      = "./instances/k8sworker"
  count                       = "${var.k8sWorkerAd2Count}"
  availability_domain         = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[1],"name")}"
  compartment_ocid            = "${var.compartment_ocid}"
  display_name_prefix         = "k8s-worker-ad2"
  domain_name                 = "${var.domain_name}"
  hostname_label_prefix       = "k8s-worker-ad2"
  oracle_linux_image_name     = "${var.worker_ol_image_name}"
  label_prefix                = "${var.label_prefix}"
  region                      = "${var.region}"
  shape                       = "${var.k8sWorkerShape}"
  ssh_private_key             = "${module.k8s-tls.ssh_private_key}"
  ssh_public_key_openssh      = "${module.k8s-tls.ssh_public_key_openssh}"
  subnet_id                   = "${module.vcn.k8worker_subnet_ad2_id}"
  tenancy_ocid                = "${var.compartment_ocid}"
  worker_iscsi_volume_create  = "${var.worker_iscsi_volume_create}"
  worker_iscsi_volume_size    = "${var.worker_iscsi_volume_size}"
  worker_iscsi_volume_mount   = "${var.worker_iscsi_volume_mount}"
}

module "instances-k8sworker-ad3" {
  source                      = "./instances/k8sworker"
  count                       = "${var.k8sWorkerAd3Count}"
  availability_domain         = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[2],"name")}"
  compartment_ocid            = "${var.compartment_ocid}"
  display_name_prefix         = "k8s-worker-ad3"
  domain_name                 = "${var.domain_name}"
  hostname_label_prefix       = "k8s-worker-ad3"
  oracle_linux_image_name     = "${var.worker_ol_image_name}"
  label_prefix                = "${var.label_prefix}"
  region                      = "${var.region}"
  shape                       = "${var.k8sWorkerShape}"
  ssh_private_key             = "${module.k8s-tls.ssh_private_key}"
  ssh_public_key_openssh      = "${module.k8s-tls.ssh_public_key_openssh}"
  subnet_id                   = "${module.vcn.k8worker_subnet_ad3_id}"
  tenancy_ocid                = "${var.compartment_ocid}"
  worker_iscsi_volume_create  = "${var.worker_iscsi_volume_create}"
  worker_iscsi_volume_size    = "${var.worker_iscsi_volume_size}"
  worker_iscsi_volume_mount   = "${var.worker_iscsi_volume_mount}"
}

### Load Balancers

module "k8smaster-public-lb" {
  source                = "./network/loadbalancers/k8smaster"
  master_oci_lb_enabled = "${var.master_oci_lb_enabled}"
  compartment_ocid      = "${var.compartment_ocid}"
  is_private            = "${var.k8s_master_lb_access == "private" ? "true": "false"}"

  # Handle case where var.k8s_master_lb_access=public, but var.control_plane_subnet_access=private
  k8smaster_subnet_0_id     = "${var.k8s_master_lb_access == "private" ? module.vcn.k8smaster_subnet_ad1_id: coalesce(join(" ", module.vcn.public_subnet_ad1_id), join(" ", list(module.vcn.k8smaster_subnet_ad1_id)))}"
  k8smaster_subnet_1_id     = "${var.k8s_master_lb_access == "private" ? "": coalesce(join(" ", module.vcn.public_subnet_ad2_id), join(" ", list(module.vcn.k8smaster_subnet_ad2_id)))}"
  k8smaster_ad1_private_ips = "${module.instances-k8smaster-ad1.private_ips}"
  k8smaster_ad2_private_ips = "${module.instances-k8smaster-ad2.private_ips}"
  k8smaster_ad3_private_ips = "${module.instances-k8smaster-ad3.private_ips}"
  k8sMasterAd1Count         = "${var.k8sMasterAd1Count}"
  k8sMasterAd2Count         = "${var.k8sMasterAd2Count}"
  k8sMasterAd3Count         = "${var.k8sMasterAd3Count}"
  label_prefix              = "${var.label_prefix}"
  shape                     = "${var.k8sMasterLBShape}"
}
