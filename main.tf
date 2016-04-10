#
# This terraform configuration brings up:
#
#  - 1 nginx web/load balancer node
#  - 2 golang app servers
#

## VARIABLES ##

# SSH Public Key
variable "ssh_key_file" {
    default = "~/.ssh/screeningtest.pub"
}

# Number of web nodes to create
variable "web_node_count" {
    default = 1
}

# Number of app nodes to create
variable "app_node_count" {
    default = 2
}

# Import our common module that contains our
# Chef validation key
module "common" {
    source = "./modules/common"
}

## RESOURCES ##

# Add the SSH public key to DigitalOcean
resource "digitalocean_ssh_key" "screeningtest" {
    name = "screeningtest"
    public_key = "${file(var.ssh_key_file)}"
}

# Create the app servers(s)
resource "digitalocean_droplet" "app" {
    image = "ubuntu-14-04-x64"
    name = "app-${count.index+1}"
    region = "lon1"
    size = "512mb"
    count = "${var.app_node_count}"
    ssh_keys = [ "${digitalocean_ssh_key.screeningtest.id}" ]
    user_data = <<EOF
#cloud-config
chef:
  install_type: "omnibus"
  omnibus_url: "https://www.opscode.com/chef/install.sh"
  force_install: false
  server_url: "https://api.opscode.com/organizations/screeningtest"
  node_name: "app-${count.index+1}"
  exec: true
  run_list:
    - role[app]
  validation_key: |
${module.common.validation_key}
  validation_name: "screeningtest-validator"
runcmd:
  - while [ ! -e /usr/bin/chef-client ]; do sleep 5; done; chef-client -i 60 -d
output: {all: '| tee -a /var/log/cloud-init-output.log'}
disable_ec2_metadata: true
EOF
    connection {
        user = "root"
        type = "ssh"
        key_file = "${var.ssh_key_file}"
        timeout = "2m"
    }
}

# Create the web server(s)
resource "digitalocean_droplet" "web" {
    image = "ubuntu-14-04-x64"
    name = "web-${count.index + 1}"
    region = "lon1"
    size = "512mb"
    count = "${var.web_node_count}"
    ssh_keys = [ "${digitalocean_ssh_key.screeningtest.id}" ]
    user_data = <<EOF
#cloud-config
chef:
  install_type: "omnibus"
  omnibus_url: "https://www.opscode.com/chef/install.sh"
  force_install: false
  server_url: "https://api.opscode.com/organizations/screeningtest"
  node_name: "web-${count.index+1}"
  exec: true
  run_list:
    - role[web]
  validation_key: |
${module.common.validation_key}
  validation_name: "screeningtest-validator"
runcmd:
  - while [ ! -e /usr/bin/chef-client ]; do sleep 5; done; chef-client -i 60 -d
output: {all: '| tee -a /var/log/cloud-init-output.log'}
disable_ec2_metadata: true
EOF
    connection {
        user = "root"
        type = "ssh"
        key_file = "${var.ssh_key_file}"
        timeout = "2m"
    }
}

# Output the IP address of where to find the service
output "url" {
    value = "http://${digitalocean_droplet.web.ipv4_address}/"
}

