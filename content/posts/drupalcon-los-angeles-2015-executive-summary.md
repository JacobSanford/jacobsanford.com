---
title: "DrupalCon Los Angeles (2015): Executive Summary"
date: 2015-05-21T15:13:30-04:00
comments: true
tags: ["drupalcon", "drupal"]
---
_The following is a brief snippet of an executive summary prepared after Drupalcon, Los Angeles in 2015_.

## Ditch our VM Mindset
We should step back and re-evaluate our VM-Focused mindset.

It is no secret that our server usage / computational density is very light, which is is costly and drastically increases our maintenance burden.  This is a side effect of standardizing our deployment processes to use one VM per application - particularly with Islandora instances.

Although it was a necessary step to structure and standardize how we spin-up new projects, with a limit of 12-15 projects per server, we will repeatedly need to expand to handle increasing capacity as new projects arise, despite VM hosts running at 5-10% utilization most of the time. We also are operating an entire OS, Database Server, Web Daemon, etc. for each project. This isn't efficient.

More important than the density issue, however, is that we are operating in a way that does not scale. If one project quickly needs more resources or becomes very popular, there is no way in our current method of work to add capacity without purchasing new hardware or taking drastic steps to shuffle and alter VM deployments. This is evidenced most recently when we added a new VM host : instances needed significant downtime and effort on our part to migrate to the new hardware.

I think it is important to start conversations around changing this. If conceptually we begin to alter how we view our infrastructure and services - and start implementing projects as 'containers' and work towards a load balanced infrastructure, we can:

- Reduce hardware requirements and costs drastically
- Handle growth more elegantly
- Adapt to needs quickly without necessitating drastic changes.
- Maintain the controlled deployment and structured configuration that we need.
- Reduce our maintenance burden significantly.

### Containers?

Instead of abstracting at a high (VM) level, containers abstract resources at the operating system level. They exist as isolated instances (As they do now at the VM level), however the overhead per container is minimal and the number of containers per server is only limited by hardware restrictions. We could start now : certainly start dropping in containers in the same way we use VMs. This would skyrocket our efficiency, but do nothing for the scaling problem.

Hosts like Pantheon are doing spectacular things with "containerization" of projects. Most commercial infrastructure is based on custom development, but there are two open source abstraction applications that are in currently in use now by Universities like Duke.

I believe we should consider Kubernetes, which provides:

- Scalable Management of applications as containers
  - https://github.com/googlecloudplatform/kubernetes
- Load balancing and container management through a Replication Controller
- Network Block Storage (network) for consistent data across containers

There are currently two competing container formats:

- Docker: https://docs.docker.com/faq/ 
- Rkt: https://github.com/coreos/rkt

Docker appears to be the leading product.

### Further Reading:

- https://docs.google.com/document/d/1uQksK49qtkYFLUWyPeLBy2Ugs7nTgL13aVDujOOY2mc/edit
- https://events.drupal.org/losangeles2015/sessions/php-containers-scale-5k-containers-server
- https://groups.drupal.org/docker

## Drush Makefiles are dead
We should migrate away from Drush makefiles and begin relying on composer to control and build our Drupal instances.

The community has recently (last month) launched a packagist mirror of all drupal modules that can build entire drupal suites from scratch. Composer is the current future of dependency building in PHP applications, and it makes sense for us to standardize to using it.

Our deployment system currently relies on drush makefiles and "[rewriting the actual files themselves would involve paying back a lot of technical debt](http://cambrico.net/drupal/using-composer-to-build-your-drupal-7-projects)". The benefit to using composer files is pretty great.  One benefit: Composer caches and handles version upgrades really elegantly, whereas drush make starts from scratch every time. This takes time and bandwidth and resources.

## There is an enormous community behind using Drupal as 'headless'. This will potentially change the way we see and use Drupal.
There were several sessions around Headless Drupal : using Drupal only as a backend content repository/editing interface, but with a front-end provided by a different framework and populated via REST.

{{< youtube 0ARnhwcI74g >}}

## Elasticsearch will (eventually) replace Solr
Elasticsearch is scalable, containerized.

{{< youtube HjYnM0-yEoI >}}
