---
layout: post
title: "A Solution for boot2docker issue #581?"
date: 2016-02-18 08:28:35 -0400
comments: true
sidebar: false
categories: docker boot2docker osx
---

Already discussed to death, [boot2docker issue #581](https://github.com/boot2docker/boot2docker/issues/581) (18 months ago) reported that _docker volumes_ from the OSX disk will not allow writes if the user insider the docker container writing the file isn't root, even with proper ownership set. We've looked at this before.

There are several work-arounds proposed, I thought we could investigate the most promising one. The first step, however is to:

## Reproduce the issue
On OSX, using the latest version of [Docker Toolbox](https://github.com/docker/toolbox), provision the affected environment:

{% highlight ruby %}
> docker-machine create --driver virtualbox docker-machine-test-581
Running pre-create checks...
Creating machine...
(docker-machine-test-581) Creating VirtualBox VM...
(docker-machine-test-581) Creating SSH key...
(docker-machine-test-581) Starting VM...
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
To see how to connect Docker to this machine, run: docker-machine env docker-machine-test-581

> eval "$(docker-machine env docker-machine-test-581)"
>
{% endhighlight %}

A simple bash script helps us reproduce the behavior : Mount a file in a docker volume with proper permissions assigned and attempt to write to it within the container as non-root.

{% gist 67ef08c785399ad6807a test_581.sh %}

Some of the paths may differ, depending on your OSX short account name. Running the script:

{% highlight ruby %}
> curl -O https://gist.githubusercontent.com/JacobSanford/67ef08c785399ad6807a/raw/152e10d25c8b43254dde0d6217026e28fffbf410/test_581.sh && chmod +x test_581.sh
> ./test_581.sh
mv: can't rename '/data-test/test.txt': Permission denied
{% endhighlight %}

we see that user ```postgres``` (_id=70 on alpine:3.1_) was denied write access to a file they own on the 'host' system mounted into the container through a docker volume.

Why? Recall that the idea of a local path in a volume statement is misleading, as the docker host is not the OSX machine, rather the VM provided by docker-machine. On OSX, docker-machine driven by a Virtualbox VM automatically creates a VBOXSF mount from the OSX User directory (/User/) into the VM (/User/) filesystem, scrambling the permissions.

### Control?
Is the above test valid? As a control, we may run docker directly on a linux host:

{% highlight ruby %}
> curl -O https://gist.githubusercontent.com/JacobSanford/67ef08c785399ad6807a/raw/152e10d25c8b43254dde0d6217026e28fffbf410/test_581.sh && chmod +x test_581.sh
> sed -i 's|/Users/jsanford/|/home/jsanford/|g' test_581.sh
> ./test_581.sh
> ls data
  test2.txt
{% endhighlight %}

## Solution : Convert VBOXSF to NFS?
[docker-machine-nfs](https://github.com/adlogix/docker-machine-nfs) is a helper that converts the ```/User``` share from VBOXSF to NFS after provisioning. Set-up is simple:

{% highlight ruby %}
> curl -s https://raw.githubusercontent.com/adlogix/docker-machine-nfs/master/docker-machine-nfs.sh |
  sudo tee /usr/local/bin/docker-machine-nfs > /dev/null && \
  sudo chmod +x /usr/local/bin/docker-machine-nfs
> docker-machine-nfs docker-machine-test-581
    [INFO] Configuration:

        - Machine Name: docker-machine-test-581
        - Shared Folder: /Users
        - Mount Options: noacl,async
        - Force: false

    [INFO] machine presence ...             OK
    [INFO] machine running ...             OK
    [INFO] Lookup mandatory properties ... OK

        - Machine IP: 192.168.99.101
        - Network ID: vboxnet1
        - NFSHost IP: 192.168.99.1

    [INFO] Configure NFS ...

     !!! Sudo will be necessary for editing /etc/exports !!!
                            OK
    [INFO] Configure Docker Machine ...         OK
    [INFO] Restart Docker Machine ...         OK
    [INFO] Verify NFS mount ...             OK

    --------------------------------------------

     The docker-machine 'docker-machine-test-581'
     is now mounted with NFS!

     ENJOY high speed mounts :D

    --------------------------------------------
{% endhighlight %}

And running our test reveals:

{% highlight ruby %}
> ./test_581.sh
mv: can't rename '/data-test/test.txt': Permission denied
{% endhighlight %}

This didn't change anything. Why? A NFS server defaults to mapping all UIDs from the client (boot2docker VM) into the local account '-2' (nobody) for security concerns. We trust the VM, so We overcome this with ```-maproot=0```, instucting the OSX nfs server to map VM root requests to our local root account. This will allow writes on the VM through the docker daemon.

To verify, we start over and re-run ```docker-machine-nfs``` with this option:

{% highlight ruby %}
> docker-machine rm docker-machine-test-581
> docker-machine create --driver virtualbox docker-machine-test-581
> docker-machine-nfs docker-machine-test-581 --nfs-config="-maproot=0"
> ./test_581.sh
> ls data
test2.txt
{% endhighlight %}

Success? Or wizardry that creates an all-you-can-eat buffet WRT file permissions? To check:

{% highlight ruby %}
> sed -i '' 's|70:70|71:71|g' test_581.sh
> ./test_581.sh
  mv: can't rename '/data-test/test.txt': Permission denied
{% endhighlight %}

Success! This is a great development for .. well.. local docker development.
