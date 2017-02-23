---
layout: post
title: "Hodor for Slack"
date: 2016-02-28 19:11:08 -0400
comments: true
sidebar: false
categories: slack docker hodor
---
Long awaited fresh updates to the famous Hodor for Slack bot Docker Image. My life's work, it leverages [python-rtmbot](https://github.com/slackhq/python-rtmbot) and [python-rtmbot-hodor](https://github.com/JacobSanford/python-rtmbot-hodor) to monitor any mentions of Hodor's name in a Slack channel and reply with a message:

![alt text](https://raw.githubusercontent.com/JacobSanford/docker-slack-hodor/master/media/hodor_image_1.png "Hodor in Action")

Hodor's replies are [determined by mood](https://github.com/JacobSanford/python-rtmbot-hodor/blob/master/Hodor/HodorActions.py).

The 'mood' of reply is determined by comparing the content of the triggering message against a [library of words and human interpreted intent scoring](https://github.com/JacobSanford/python-rtmbot-hodor/blob/master/Hodor/HodorMoodIndex.py). After mood assignment, a message is chosen based on a 'item drop' type selection process that allows for weighting of responses.

## Quick Start
1. [Add a bot user](https://api.slack.com/bot-users) to your slack team and obtain the API token.
2. Deploy the image, passing to it the API token in the ```SLACK_TOKEN``` environment variable:
```
docker run \
       --rm \
       --name hodorbot \
       -e SLACK_TOKEN=_API_TOKEN_OBTAINED_FROM_SLACK_INTEGRATION_ \
       jacobsanford/slack-hodor
```

At some point in the future I hope to leverage [pickle](https://docs.python.org/2/library/pickle.html) or a key-value store such as [redis](http://redis.io/) to help Hodor 'remember' how people treat him.
