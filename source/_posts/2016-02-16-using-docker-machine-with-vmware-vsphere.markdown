---
layout: post
title: "Using docker-machine With VMWare VSphere"
subtitle: "This is a subtitle"
date: 2016-02-16 12:32:51 -0400
comments: true
sidebar: false
categories: docker docker-machine vmware vsphere
---

## Docker-Machine and VSphere
By default, ```docker-machine``` leverages Virtualbox to deploy a Boot2Docker VM to serve as a docker endpoint. This configuration satisfies the common use case when developing on OSX, but does suffer from a few drawbacks, including persistence and the use of VBoxFS. Instead, one may wish to deploy the Boot2Docker VM on vSphere managed hardware.

### 1. Install GovC

[govc](https://github.com/vmware/govmomi/tree/master/govc) is a vSphere CLI utility built on top of govmomi, a [go library for the VMware vSphere API](https://github.com/vmware/govmomi).

#### a. Install go
Download the latest [go package installer](http://golang.org/dl/). To verify that everything is working:

{% codeblock lang:bash %}
go version
go version go1.4.2 darwin/amd64
{% endcodeblock %}

#### b. Set up the go build environment

**bash shell**
{% codeblock lang:bash %}
export GOPATH=$HOME/src/go
mkdir -p $GOPATH
export PATH=$PATH:$GOPATH/bin
{% endcodeblock %}

**fish shell**
{% codeblock lang:bash %}
set -Ux GOPATH $HOME/src/go
mkdir -p $GOPATH
set --universal fish_user_paths $fish_user_paths $GOPATH/bin
{% endcodeblock %}

#### c. Download govc
{% codeblock lang:bash %}
go get github.com/vmware/govmomi/govc
{% endcodeblock %}

### 2. Export the 2 Necessary Environment Variables and Test Connection to vSphere
govc needs environment variables set to communicate with the vSphere instances.

{% codeblock lang:bash %}
export GOVC_URL=https://docker:*PASSWORD*@131.202.94.116/sdk
export GOVC_INSECURE=1
{% endcodeblock %}

You can then test the connection:

{% codeblock lang:bash %}
govc about
{% endcodeblock %}

{% codeblock %}
Name:         VMware ESXi
Vendor:       VMware, Inc.
Version:      5.5.0
Build:        2718055
OS type:      vmnix-x86
API type:     HostAgent
API version:  5.5
Product ID:   embeddedEsx
UUID:
{% endcodeblock %}

### 3. Deploy a New VM with docker-machine
govc needs environment variables set to communicate with the vSphere instances.

{% codeblock %}
docker-machine create -d vmwarevsphere \
  --vmwarevsphere-vcenter="131.202.94.116" \
  --vmwarevsphere-username="docker" \
  --vmwarevsphere-password="*PASSWORD*" \
  --vmwarevsphere-datacenter="ha-datacenter" \
  --vmwarevsphere-compute-ip="131.202.94.116" \
  --vmwarevsphere-datastore="datastore1" \
  --vmwarevsphere-network="HIL.Building01" \
  --vmwarevsphere-cpu-count=4 \
  --vmwarevsphere-memory-size=4096 \
  docker-jake
{% endcodeblock %}
