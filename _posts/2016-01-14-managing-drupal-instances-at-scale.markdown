---
layout: post
title: "Re-Thinking Workflows : Development and Maintenance of Drupal Instances at Scale"
date: 2016-01-14 14:33:58 -0400
comments: true
sidebar: false
categories: drupal git github jenkins drush
---
For the past several years, we have been developing and managing a moderate amount of Drupal instances across several VM datacenters and Hosts using a homegrown product we call [pushback](https://github.com/unb-libraries/pushback). It leverages [drush](https://github.com/drush-ops/drush) in conjunction with [Jenkins](https://jenkins-ci.org/) and gitHub. Why develop a custom framework? Although several products existed [[1]](http://www.aegirproject.org/) [[2]](https://www.drupal.org/project/drd), none seemed to meet our desire for simplicity and maintainability.

Pushback was born conceptually through discussions with [Jen Whitney](https://github.com/jwhitney) and [Kassim Machioudi](https://twitter.com/kaschioudi), and was inspired by the (now-abandoned) [Tugboat project by Lullabot](https://github.com/Lullabot/jenkins_github_drupal). It is simple and does nothing novel. A summary:

+ Establish a core, standardized single-instance repository format in a git repository that describes and controls the deployment of a site. It contains a drush makefile, install profiles, data, patches, and CasperJS tests for the application's UI.
+ From this repository, builds are triggered via a post-commit hook to Jenkins from GitHub.
+ Jenkins then builds the instance locally, optionally testing the local copy.
+ If the build is successful, the Drupal is then transferred via rsync to the _prod_ server (with optional deployment to a _staging_ server first).
+ General post-deploy tasks are run, including database updates, clearing the cache, and checking permissions.

This workflow delivered very positive benefits (especially for our small team):

+ Module updates and security releases are almost effortless, as one needed only change version numbers in Drush Makefiles, and push to GitHub. Network-wide updates could be done in a single commit with a tool such as [unb-libraries/bulk-repo-find-replace](https://github.com/unb-libraries/bulk-repo-find-replace).
+ Extremely smooth development of existing Drupal instances: One-button spin up and database/file transfer into a local development clone using a Chef Server (Chef-solo never felt right for our use case), a [A Drupal Cookbook](https://github.com/unb-libraries/unblibraries-drupal) and customized Vagrants.

It worked great. It did what we needed. But, as we began to challenge our workflow and infrastructure in the past 18 months, several general discussions kept recurring:

+ We develop and maintain Drupal instances in a completely different environment compared to staging and production. This often introduces small gotchas. Can we eliminate some of these problems by making _dev_ and _prod_ more alike?
+ Local development of a existing instances using Vagrant take upwards of 30 minutes to spin up, and still depends heavily on network connectivity. This and other quirks of the (otherwise solid) vagrant model are becoming increasingly frustrating. Vagrant itself seems to be [struggling with its role in a modern infrastructure](http://thenewstack.io/hashicorp-revamps-vagrant-and-retools-for-microservices/). Are we asking too much of Vagrant?
+ The framework around the Creation, Deploy/Maintain cycle has a lot of customized moving parts. These moving parts break down often due to OS upgrades, network dependencies, caching, etc. How can we simplify the cycle to avoid some of the problems arising from complexity?
+ Our Drupal instances are not scalable. They exist on a single server, communicate with a single database instance, and only leverage Varnish caching. How can we move from this model to one that scales?
+ Jenkins is a platform designed for testing and continuous integration. We employ it more as a 'Task Runner'. Should we rethink this?
+ Our Drupal development and deployment feels completely separate from our other applications. Can we design a cohesive 'development to production' workflow that varies far less depending on the application framework?

These are difficult questions, and introduce problems not easily solved. I feel the recent rise in popularity of a container-centered infrastructure and workflow offers strong possibilities for the future.
