---
layout: post
title: "Docker Toolbox, OSX, and VirtualBox VBoxSF Permissions"
date: 2015-07-17 08:39:25 -0400
comments: true
sidebar: false
categories: docker boot2docker osx
---

If you are developing in docker on OSX, chances are you've run into a situation described by [boot2docker issue #581](https://github.com/boot2docker/boot2docker/issues/581). The issue reports that _docker volumes_ from the OSX disk will not allow writes if the user insider the docker container writing the file isn't root. This has limited effect on casual development, has become an achilles heel for those wanting to use docker as the foundation of a prototype-to-production workflow AND develop on OSX.

Why does this affect OSX specifically, and not Linux? To understand, we can quickly examine what docker volumes are, why we use _docker toolbox_, and how volumes are managed through _docker-machine_ and _boot2docker_.

## Docker Volumes
Since most applications rely on a data source of some type, docker containers would have limited use and portability if one could not expose an external filesystem to the container, or write data from the container into an external filesystem. Both are possible via _volumes_, typically defined by [_VOLUME_ declarations](https://docs.docker.com/reference/builder/) inside the _Dockerfile_.

From [Understanding Volumes in Docker](http://container-solutions.com/understanding-volumes-docker/)

> In order to understand what a Docker volume is, we first need to be clear about how the filesystem normally works in Docker. Docker images are stored as series of read-only layers. When we start a container, Docker takes the read-only image and adds a read-write layer on top. If the running container modifies an existing file, the file is copied out of the underlying read-only layer and into the top-most read-write layer where the changes are applied. The version in the read-write layer hides the underlying file, but does not destroy it — it still exists in the underlying image. When a Docker container is deleted, relaunching the image will start a fresh container without any of the changes made in the previously running container — those changes are lost. Docker calls this combination of read-only layers with a read-write layer on top a Union File System.
>
> In order to be able to save (persist) data and share data between containers, Docker came up with the concept of volumes. Quite simply, volumes are directories (or files) that are outside of the default Union File System and exist as normal directories and files on the host filesystem.

Again; host files stored outside docker and exposed to the container via a _VOLUME_ declaration are not considered as part of the container's filesystem, and the ```docker rm``` command does not remove them. They are defined at runtime (container creation) by a [VOLUME statement](https://docs.docker.com/reference/builder/). The format is:

```
docker run -v /local/path:/container/path image/name
```

which mounts a ```/local/path``` to the ```/container/path``` inside the container (and replacing any data that already exists there). This works swimmingly in linux.

## OSX - Complications Arise
When leveraging _docker-machine_ with a VM to run docker commands, however, the idea of a _local path_ in a volume statement is misleading, as the docker host is not the user's machine, rather the VM provided by _docker-machine_. Following; since the local path in a volume statement defines a path within the _docker-machine_ VM, it is problematic to expose files from the user's machine through two layers of abstraction into the docker container.

This complication is (at first glance) solved by the fact that the OSX _docker-machine_ Virtualbox VM automatically creates a VBOXSF mount from the OSX User directory (/User/) into the VM (/User/) filesystem. Volume statements using absolute paths:
```
-v /Users/dave/data/books:/var/lib/books
```
will then behave as intended, since /Users/ is shared between the host and the docker-running VM. In most cases, however, **this 'convenience' cripples the performance of the container, and often doesn't work at all**. The [VBOXSF sharing speed is poor and decreases exponentially with the number of files on disk](http://mitchellh.com/comparing-filesystem-performance-in-virtual-machines), and (most importantly) file permissions are inconsistent. This inconsistency means docker volumes from the OSX disk will not allow writes if the user insider the docker container writing the file isn't root.

## This root thing, why is it a problem?
So, what's the concern? Why not just run services as root? Most services in the 'bare metal' world are generally not run as root (apache/www-data, etc.). This is for security reasons, but do the concerns driving this apply to a single service in an isolated container?

[A post by Jérôme Petazzoni](https://groups.google.com/forum/#!msg/docker-user/e9RkC4y-21E/JOZF8H-PfYsJ) discusses this:

> The best practice is to combine:
>   1. Running your process as non-privileged user within the containers (docker lets you do that easily)
>   2. stripping the container from all the potentially dangerous system capabilities (docker does that automatically)
>   3. running an hardened Linux, with e.g. a grsec-enabled kernel, or with your distro's security module (SELinux, AppArmor...)
>
>   A root user within a LXC container cannot (in theory) escalate to be root on the host machine; but many people believe that it is possible to do so. It is certainly harder to do with Docker containers (thanks to the capability restrictions) but if security is a big concern, you should stack up multiple safety mechanisms.

For local development that isn't exposed to the world, this isn't a critical issue. If we are mounting volumes and developing in containers in a workflow that wishes to deploy containers consistently at every level of development, however, we then are unable to develop on the exact configuration that would appear in production. Tools can be created to modify container configuration upon deployment, however that introduces additional complexity.

Is this a concern? I'll leave that decision up to you.

## Solutions
This issue seems unlikely to be fixed at the boot2docker level soon. There are many workarounds proposed, each with differing complexity:

+ [Make sure that mysql runs using the same user and group ids as your local OSX user.](https://github.com/docker-library/mysql/issues/99#issuecomment-145665645)
+ [xhyve](https://github.com/mist64/xhyve)
+ Leverage NFS in some manner instead of VBOXSF.

The last solution seems to work swimmingly, but the tool recently dealt with a breaking bug. A fix has been implemented and I would encourage you to explore it further.
