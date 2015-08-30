disnix-virtualhosts-example
===========================
This is an example deploying a collection web applications and a reverse proxy
that support multiple virtual hosts. The purpose of this example is to
demonstrate how we can dynamically create target-specific services and deploy
them to the corresponding machines with Disnix.

Architecture
============
![A virtualhosts deployment](doc/deployment.png)

With this example you can automatically set up deployments as shown in the figure
above. We have two kinds of services:

* Web applications returning their virtual host name (their names are prefixed with `webapp`)
* An nginx reverse proxy per machine forwarding requests to the web applications that are deployed to the machine

In general, services in Disnix are independendent units of deployment that have
the same structure regardless to which machines they are deployed in the network.

In some cases, however, it may also be desirable to define services that are
configured for a specific target machines.

In this example, the reverse proxies are services having a *target-specific*
configuration -- their configurations are specifically optimised for the machine
to which they have been deployed. For example, the `nginx` reverse proxy on
machine `test1` only knows about the web application that have been deployed to
it.

The advantage of deploying target-specific components is that they will prevent
expensive redeployments in case of an upgrade. For example, if a change has been
to `test2`'s configuration, then `test1` should not be affected.

Usage
=====
The `deployment/DistributedDeployment` sub folder contains all neccessary Disnix
models, such as a services, infrastructure and distribution models required for
deployment.

Deployment using Disnix in a heterogeneous network
--------------------------------------------------
For this scenario only installation of the basic Disnix toolset is required.
First, you must manually install a network of machines running the Disnix service.
Then you must adapt the infrastructure model to match to properties of your
network and the distribution model to map the services to the right machines.

The system can be deployed by running the following command:

    $ disnix-env -s services.nix -i infrastructure.nix -d distribution.nix

Hybrid deployment of NixOS infrastructure and services using DisnixOS
---------------------------------------------------------------------
For this scenario you need to install a network of NixOS machines, running the
Disnix service. This can be done by enabling the following configuration
option in each `/etc/nixos/configuration.nix` file:

    services.disnix.enable = true;

You may also need to adapt the NixOS configurations to which the `network.nix`
model is referring, so that they will match the actual system configurations.

The system including its underlying infrastructure can be deployed by using the
`disnixos-env` command. The following instruction deploys the system including
the underlying infrastructure.

    $ disnixos-env -s services.nix -n network.nix -d distribution.nix

Deployment using the NixOS test driver
--------------------------------------
This system can be deployed without adapting any of the models in
`deployment/DistributedDeployment`. By running the following instruction, the
variant without the proxy can be deployed in a network of virtual machines:

    $ disnixos-vm-env -s services.nix -n network.nix -d distribution.nix

Deployment using NixOps for infrastructure and Disnix for service deployment
----------------------------------------------------------------------------
It's also possible to use NixOps for deploying the infrastructure (machines) and
let Disnix do the deployment of the services to these machines.

A virtualbox network can be deployed as follows:

    $ nixops create ./network.nix ./network-virtualbox.nix -d vboxtest
    $ nixops deploy -d vboxtest

The services can be deployed by running the following commands:

    $ export NIXOPS_DEPLOYMENT=vboxtest
    $ disnixos-env -s services.nix -n network.nix -d distribution.nix --use-nixops

Running the system
==================
After the system has been deployed, open a terminal on the third machine and
run:

    $ curl -H 'Host: webapp2.local' http://test1

Subsitute `webapp2.local` with the desired virtual hostname.

License
=======
This package is released under the [MIT license](http://opensource.org/licenses/MIT).
