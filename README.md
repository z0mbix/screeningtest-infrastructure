Screening Test Infrastructure
-----------------------------

This repo sets up the following infrastructure on DigitalOcean:

- 1 x nginx web/load balancer server (web-1)
- 2 x golang app servers (app-{1,2})

These are all Ubuntu 14.04 servers.

Terraform is used to provision the servers, and uses cloud-init to install, configure and run chef-client, so the servers can register with the Chef server and configure themselves according to their role.

Chef uses the git resource to clone the [screeningtest-app](https://github.com/z0mbix/screeningtest-app) GitHub repo, and uses a simple Makefile to build the go binary. It then creates an upstart init script to manage the service. Chef will pull the latest master branch of this repo, and if there are any changes, it will rebuild the binary and restart the process.


## Requirements

 - Linux or Mac OS
 - Terraform
 - ChefDK
 - Hosted Chef account (Including validation key)

Create the file **modules/common/terraform.tf** containing your validation key e.g.:

    output "validation_key" {
        value = <<EOF
        -----BEGIN RSA PRIVATE KEY-----
        ...
        -----END RSA PRIVATE KEY-----
    EOF
    }


## Chef

This repo uses the following supermarket cookbooks:

 - apt
 - golang

It also requires the custom 'screeningtest' cookbook with the following two recpies:

 - screeningtest::web
 - screeningtest::app

These need to be uploaded to the Hosted Chef server using knife. Knife is configured to use the organisation 'screeningtest' in the **chef-repo/.chef/knife.rb** file.

    $ cd chef-repo
    $ chef exec knife cookbook upload -a

There are two roles:

 - web
 - app


## DigitalOcean

For Terraform to be able to use the DigitalOcean API, you need to export
your API token with:

    $ export DIGITALOCEAN_TOKEN=XXXX


## Creating the infrastructure

You can perform a dry-run of what Terraform will do by running:

    $ make plan

When you are ready to create everything just run:

    $ make apply


## Destroying the infrastructure

Once you are finished with all the resources, simply destroy them with:

    $ make destroy


## Help

The **Makefile** is self-documenting so you can see the available targets with:

    $ make help
    apply                          Create the infrastructure/resources
    destroy                        Destroy all resources
    help                           See all the Makefile targets
    plan                           Perform a terraform dry-run
