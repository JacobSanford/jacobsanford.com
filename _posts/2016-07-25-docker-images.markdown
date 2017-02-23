---
layout: post
title: "Docker Images, Security, and the New Maintenance Cycle"
date: 2016-04-01 08:27:04 -0300
comments: true
sidebar: false
categories: docker travis testing ci security
---
Container management and development of a process towards keeping Docker images up to date and secure may seem like a daunting task, especially at scale. Stale images lead to [security vulnerablities](http://thenewstack.io/docker-launches-vulnerability-scanner-containers/), and this is a very real concern when administrators can [let containers run for weeks at a time without updates](https://www.datadoghq.com/docker-adoption/).

Like most early adopters, we struggled for some time to adjust our concept of a maintenance cycle within a container-driven paradigm. However, over time, we've evolved a moderately sane method for keeping our containers up to date and secure:

## Develop Comprehensive Tests for the Container
### Tests
Provide test coverage for your application, and [include them in the application repository](https://github.com/unb-libraries/loyalistresearchnet.org/tree/dev/tests). A discussion of test writing is far out of scope for this post. Some discussions and resources, some relating to Drupal:

* [Relation between BDD and TDD](http://programmers.stackexchange.com/questions/111837/relation-between-bdd-and-tdd)
* [How to do Test Driven Development (TDD) in Drupal?](http://drupal.stackexchange.com/questions/1454/how-to-do-test-driven-development-tdd-in-drupal)
* [Drupal Extension to Behat and Mink’s documentation](http://behat-drupal-extension.readthedocs.io/en/3.0/)

### Testing Tools
Ensure that the image can (optionally) be launched with the tools and means to test itself. To avoid polluting production images with testing tools and libraries, we allow an environment variable to [control the installation of testing tools](https://github.com/unb-libraries/docker-drupal/blob/alpine-nginx-php7-8.x/scripts/pre-init.d/94_install_testing_tools.sh) when launching the container.

## Build the Image and Run Tests
Once tests are developed, have your CI service: [Travis](https://travis-ci.org/) build the image and run [the tests](https://github.com/unb-libraries/docker-drupal/blob/alpine-nginx-php7-8.x/.travis.yml#L26-L38).

## Build/Push Image to Repo On Success
Upon **successful** testing, configure the CI service to [trigger a build and push](https://github.com/unb-libraries/docker-drupal/blob/alpine-nginx-php7-8.x/travis/triggerDockerHubBuild.sh) to the image repository. For our public images, this is [DockerHub](https://hub.docker.com/). For our private images, this is the [Amazon EC2 Container Registry](https://aws.amazon.com/ecr/).

## Configure cron for builds
Most CI services offer . Travis provides repository [cronjobs](https://docs.travis-ci.com/user/cron-jobs/) upon request. Triggering a nightly rebuild and test will pull in security fixes automatically, and re-test the image using those new changes.

## Deploy Rolling Updates for Instance Nodes
In low-traffic periods, update the running containers with the new images stored in the repository. How this occurs depends entirely on your infrstructure and setup.
