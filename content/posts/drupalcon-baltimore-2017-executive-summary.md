---
title: "DrupalCon Baltimore (2017): Executive Summary"
date: 2017-04-30T18:03:30-04:00
comments: true
tags: ["drupalcon", "drupal 8"]
---
_The following is a portion of an executive summary prepared after Drupalcon, Baltimore in 2017_.

After spending the previous yeah fostering a belief that we are little shop 'on the edge', DrupalCon never fails to humble me. There are extremely intelligent people doing amazing things in the community, and the opportunity to learn and network with them is invaluable.

### Drupal 8
Surprisingly, the uptake for Drupal 8 in the community is still quite low, [despite the numbers that show steady D8 growth](https://www.drupal.org/project/usage/drupal). Several sessions I attended were focused on how to get Drupal 8 momentum moving. The lethargy in adoption is undoubtedly due to the complexity of the Dependency-Injection model and sluggish Contrib module ports from D7. Many people felt that Drupal jumped from an 'Accessible' procedural codebase to a complex 'nightmare'.

Most people I met opened our conversation with 'What version of Drupal are you on?', and seemed surprised to hear that we had standarized on D8. A lot of attendees remain locked in to Drupal 6 and were searching for advice on how they could jump to D8 with the least pain. To wit : many sessions this year remained focused on a theme of 'Getting Started In 8'. The theme of the sprints was again similar - getting [Migrate](https://www.drupal.org/project/migrate) in improved shape to help move things along. The general opinion in the Core community : people need a 'Kick in the pants' to jump to D8, and improving up Migrate might help.

### Major Version Upgrades "Easy as Minor Updates"
The slower than expected D8 adoption has spawned an investigation into how the community can make the transition between future major versions smoother. Dries, in [his "DriesNote"](https://events.drupal.org/baltimore2017/driesnote) outlined a plan towards that goal. Although ambitious, I see it as a great plan - slowly deprecating API functions (but maintaining backwards compatibility) through minor releases, finally ending support only with major releases.

Theoretically this makes Major version updates as easy as minor ones. We'll see!

### Us, Deployment Dinosaurs
With costs falling, the value offered by fully managed Hosting services grows each year. Because of this, most users are moving to Pantheon-like ([Pantheon](https://pantheon.io/), [Platform.sh](https://platform.sh/), [Acquia Cloud](https://www.acquia.com/products-services/acquia-cloud)) hosting platforms that handle sane deployment, testing, and configuration management for the user. Fewer people were interested in discussing details of instance deployment this year, as this is handled for them upstream by these servies.

Our local infrastructure investment currently discourages us from moving in that direction. As we consider the slow adoption of cloud resources, however, we should include a consideration our 'deployment stack' in the cost comparison. Maintenance of a custom deployment system will be an ongoing cost. This cost is amplified by the fact that every few years, a firebrand will return from a conference looking to retool part of said system.

That isn't to say there were not people at DrupalCon who remain interested discussing development workflows: I spoke to several DevOps-oriented people at length about our deployment system.

[Greg Anderson](https://pantheon.io/team/greg-anderson) (Drush co-maintainer) from Pantheon sat down and went through how we approach the developer-to-prod workflow. He offered some suggestions, but seemed adamant that we strip Node.js from our workflow and leverage only PHP tools (RoboPHP) and Composer more. This would simplify our workflow significantly and require less tools on the development instance.

### No More Woes with Biblio
I attended a BOF session with the team behind the [bibcite](https://www.drupal.org/project/bibcite) module, the new replacement for biblio in D8. The maintainers are a group of young developers, and seem motivated and talented. The take-away : the module is looking for people to start using the module extensively now and help them steer the ship. I think this is what we've been waiting for - and could be a great partnership.

### Islandora is Dockerizing, Properly
Speaking of Islandora; I had lunch with [Noah Smith](https://twitter.com/natchiq), CEO of Common Media. We had met previously at IslandoraCon 2 years ago. They've been workign as partners with the Islandora Foundation and have ambitions to get the whole ecosystem Dockerized. He lamented how all the brains from the community left when CLAW was started, then CLAW was abandoned. Overall he seemed positive about their efforts and suggested we attend the upcoming camp in upper Canada.

### Visual Regression Tools
I attended a [session on automatic updates for Drupal sites through visual regression testing](https://events.drupal.org/baltimore2017/sessions/automatic-drupal-updates-using-visual-regression-continious-integration) and tool based validation. This sparked an idea for a method that could work well for us and eliminate some of the pain of module updates.

### Headless / Conversational / Chat Interfaces Abound!
I'm not sure if it is the influence of Dries ([who seems](http://buytaert.net/cross-channel-user-experiences-with-drupal) clearly [driven](http://buytaert.net/the-big-reverse-of-the-web) in [this direction](http://buytaert.net/drupal-is-api-first-not-api-only)), but non-standard interfaces held the focus of many of the sessions and discussions.

NBA.com is [driving voice interface and headless](https://events.drupal.org/baltimore2017/sessions/building-nbacom-drupal-8) development strongly with Drupal. People are coupling [angular.js](https://angularjs.org/) with Drupal for headless user experiences now, and they're having success.

I attended a session where the presenters leveraged [Drupal, Amazon, and a Big Mouth Billy Bass](https://events.drupal.org/baltimore2017/sessions/drupal-alexa-and-big-mouth-billy-bass-walk-bar) to tell jokes. Although a 'surface' implementation, it does make one think: could Libraries be a great incubator for conversational interfaces? Could we provide patrons with augmented experiences by leveraging this technology? Food for thought, especially as we move slowly towards a main library site redesign. __Something in this vein could be a fantastic PR strikepoint for us__.

### Modules are Dead, Long Live Modules
The elimination of the 'project approval' queue has changed the ecosystem a bit. With contrib modules no longer requiring a review before being an 'Official' project, we have to be increasingly vigilant in vetting modules before adopting them. There was a concern in the air about users launching instances with modules that had no hope of maintenance.

## Conclusions
To summarize, some actionables to consider:

- Further reducing the complexity of our workflow, to help people get working faster.
- Continuing discussions around long-term cloud migration
- Investigating 'new' interfaces and how they could be used stars in the library portfolio
- Begin rolling out bibcite instead of biblio
