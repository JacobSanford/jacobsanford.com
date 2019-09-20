---
layout: post
title: "Deploying a docker-machine to a VMWare VSphere Host"
subtitle: "This is a subtitle"
date: 2015-10-12T12:32:51-0400
comments: true
warning: "This is a legacy article that references docker-machine, which is no longer the recommended method for OSX/docker development. It is recommended you use Docker for Mac."
tags: ["docker", "docker-machine", "osx", "vmware", "vsphere"]
---

## Docker-Machine and VSphere
By default, ```docker-machine``` on OSX leverages Virtualbox to deploy a Boot2Docker VM to serve as an endpoint for the host docker commands. This configuration satisfies a common use case for development, but does suffer from drawbacks relating to "the 3 P's" : Performance, Persistence and Permission issues ([due to VBoxSF](https://github.com/boot2docker/boot2docker/issues/581)). You can dodge some of these by provisioning Boot2Docker VM on a vSphere managed host, instead of your local computer.

If you have access to a VMWare VSphere host, the steps are as follows:

### 1. Determine your VSphere user credentials
This post assumes you have credentials for a remote user on VSphere, which will be referred to as ```vsphere-user```. It is recommended that you not use the root account. For additional assistance, see [VMWare KB #2082641](https://kb.vmware.com/selfservice/microsites/search.do?language=en_US&cmd=displayKC&externalId=2082641).

### 2. Install GovC (OSX)

[govc](https://github.com/vmware/govmomi/tree/master/govc) is a vSphere CLI utility built on top of govmomi, a [go library for the VMware vSphere API](https://github.com/vmware/govmomi). It is necessary to automatically provision a virtual machine on the VMWare host using ```docker-machine```. To install ```govc```

#### a. Install go
The package ```govc``` is built on [go](https://golang.org/), and requires it to run. Download the latest [go package installer](http://golang.org/dl/). Run the installer, then verify  ```go``` is working correctly:

{{< highlight bash >}}
> go version

go version go1.4.2 darwin/amd64
{{< / highlight >}}

#### b. Set up the go build environment

To build ```govc```, we will need to set up the ```go``` build environment. To do so:

Using ```bash shell```
{{< highlight bash >}}
> export GOPATH=$HOME/src/go
> mkdir -p $GOPATH
> export PATH=$PATH:$GOPATH/bin
{{< / highlight >}}

Using ```fish shell```
{{< highlight bash >}}
> set -Ux GOPATH $HOME/src/go
> mkdir -p $GOPATH
> set --universal fish_user_paths $fish_user_paths $GOPATH/bin
{{< / highlight >}}

#### c. Install govc

Now that ```go``` is installed, we can install ```govc```.

{{< highlight bash >}}
> go get github.com/vmware/govmomi/govc
{{< / highlight >}}

### 3. Export Environment Variables and Test vSphere Host Connection
The package ```govc``` needs environment variables set to communicate with the vSphere host. To set them:

Using ```bash shell```
{{< highlight bash >}}
> export GOVC_URL=https://vsphere-user:*PASSWORD*@192.168.0.10/sdk
> export GOVC_INSECURE=1
{{< / highlight >}}

Using ```fish shell```
{{< highlight bash >}}
> set -Ux GOVC_URL https://vsphere-user:*PASSWORD*@192.168.0.10/sdk
> set -Ux GOVC_INSECURE 1
{{< / highlight >}}

Where ```192.168.0.10``` is the IP address of your vSphere host. You may then test ```govc```:

{{< highlight bash >}}
> govc about

Name:         VMware ESXi
Vendor:       VMware, Inc.
Version:      5.5.0
Build:        2718055
OS type:      vmnix-x86
API type:     HostAgent
API version:  5.5
Product ID:   embeddedEsx
UUID:
{{< / highlight >}}

### 4. Deploy a New VM with docker-machine
We are now able to provision a new docker-machine instance on the VSphere host. To do so:

{{< highlight bash >}}
> docker-machine create -d vmwarevsphere \
  --vmwarevsphere-vcenter="192.168.0.10" \
  --vmwarevsphere-username="docker" \
  --vmwarevsphere-password="*PASSWORD*" \
  --vmwarevsphere-datacenter="ha-datacenter" \
  --vmwarevsphere-compute-ip="192.168.0.10" \
  --vmwarevsphere-datastore="datastore1" \
  --vmwarevsphere-network="NET.Building01" \
  --vmwarevsphere-cpu-count=4 \
  --vmwarevsphere-memory-size=4096 \
  docker-vsphere-host

Running pre-create checks...
Creating machine...
(docker-vsphere-host) Generating SSH Keypair...
(docker-vsphere-host) Uploading Boot2docker ISO ...
(docker-vsphere-host) Creating directory docker-vsphere-host on datastore datastore1 of vCenter 192.168.0.10...
(docker-vsphere-host) Uploading /Users/jsanford/.docker/machine/boot2docker.iso to docker-vsphere-host on datastore datastore1 of vCenter 192.168.0.10...
(docker-vsphere-host) Creating virtual machine docker-vsphere-host of vCenter 192.168.0.10...
(docker-vsphere-host) Configuring the virtual machine docker-vsphere-host...
(docker-vsphere-host) Powering on virtual machine docker-vsphere-host of vCenter 192.168.0.10...
Waiting for machine to be running, this may take a few minutes...
Machine is running, waiting for SSH to be available...
Detecting operating system of created instance...
Detecting the provisioner...
Provisioning with boot2docker...
Copying certs to the local machine directory...
Copying certs to the remote machine...
Setting Docker configuration on the remote daemon...
Checking connection to Docker...
Docker is up and running!
To see how to connect Docker to this machine, run: docker-machine env docker-vsphere-host
{{< / highlight >}}

### 5. Run docker commands on the new VSphere instance.
To run commands on the newly deployed instance, we must first define environment variables so any docker commands are routed to the newly-created VSphere VM endpoint. ```docker-machine``` can tell us how to do so:
{{< highlight bash >}}
> docker-machine env docker-vsphere-host

set -gx DOCKER_TLS_VERIFY "1";
set -gx DOCKER_HOST "tcp://192.168.0.101:2376";
set -gx DOCKER_CERT_PATH "/Users/jsanford/.docker/machine/machines/docker-vsphere-host";
set -gx DOCKER_MACHINE_NAME "docker-vsphere-host";
# Run this command to configure your shell:
# eval (docker-machine env docker-vsphere-host)
{{< / highlight >}}

Running that command:
{{< highlight bash >}}
> eval (docker-machine env docker-vsphere-host)
> docker ps

CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
{{< / highlight >}}

All docker commands will now run on the VSphere host.
