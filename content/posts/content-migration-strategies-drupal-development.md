---
title: "Content Migration Strategies : Drupal Development"
date: 2017-11-27T11:13:00-04:00
draft: true
comments: true
tags: ["content migration", "content", "migration", "drupal"]
---
## Backgrounder
The familiar policy a lot of development development teams use is the 'PROD is Canonical for Content' model. In it, Content is developed on the highest server environment, and it (as well as configuration in D8) cascades downward through the environments (PROD-> STAGE -> QA/UAT-> DEV), but not upward.

The 'not-upward' rule is a policy to introduce sanity in group development, and isn't a technical challenge. It provides an easy model for each member of the team to understand what content is canonical, and what is disposable. This avoids misunderstandings and reduces risk of time and resource losses.

This rule can be broken! If the whole team is aware, migrating content upward through environments is not disasterous, as the net result is the same : the content in the environments ends up identical. Unless the entire team is aware of these moves when they occur, you risk content deletion where it wasn't expected. 

If choose to use this model, a tool you must to have on the OPS side is a way to 'one-button' migrate content between the server environments on demand. This isn't something that is going to only occur rarely, and may be done many dozens of times throughout a development cycle. Not having a codified way to do so automatically invites errors, introduces risk, and wastes a lot of time IMHO.

Also, another very important part of the system is a DEVOPS-y method for developers to 'one-button' pull down content from the lowest server environment (typically DEV) into their local development instance. Why? If not, developers cannot develop in environments that match those upstream, and that leads to time losses and adds a large risk item to each project. 

## Content
What is content? For Drupal, this typically means:

D7: Database content, /sites/default/files/* (or /sites/*URI*/files, depending on how you have it setup).
D8: Database content, site configuration, /sites/default/files/*

How are these done? Well, this depends a lot on your server environment and how you have each environment configured. If you are building and deploying to each level consistently (including LOCAL), then things get a lot simpler. Drush provides tools to move database content and files between installed Drupal instances, but it certainly isn't necessary to accomplish the two goals listed above. I am always a big fan of the KISS approach, and Jenkins Job(s) that trigger simple scripts could be used for [#1].

For [#2], (here at the library) we have grunt tasks that live in the site repo that trigger shell scripts that pull the DEV content down to local, but I'm completely ignorant about Ops, as well as your standards and best practices at BlueSpurs.

We're embarking on a new policy to open-source EVERY site we build at the library going forward, so we've been diligently tidying up our deploy tools to make them suitable for public consumption. If you need a starting point, or a poke in the right direction, I could send over a rough sneak peek.