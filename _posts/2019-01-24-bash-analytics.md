---
layout: post
title: Analyzing an Apache Log File
comments: false
categories: DevOps, Docker, Apache, Makefile, Bash
---

Pop quiz, hot shot! You need to quickly get an idea of the top 5 clients IPs
of your website grouped by path and HTTP status code but only between 6PM and
7PM and only for requests with HTTP status code 40x. Quick! What tools do
you pick up? Do you use go, python, C? What about the framework? And how do
you onboard the rest of your team?

Slow down, take a deep breath. For this scenario, you don't need anything more
than Bash and friends. To get an idea of how to do that, try out this 60-liner
bash script to get the data I mentioned above.

Run [Bash Analytics](https://github.com/relaxdiego/bash-analytics) like so:

```
script/ba \
    --logfile samples/access_log \
    --group src,path,code \
    --top 5 \
    --filter timestamp=07/Mar/2004:1[8-9],code=40.
```

<br/>
From that command you can get something like:

```
1 64.242.88.10 /twiki/bin/edit/TWiki/TWikiVariables?t=1078684115 401
1 64.242.88.10 /twiki/bin/edit/Sandbox/TestTopic5?topicparent=Sandbox.WebHome 401
1 64.242.88.10 /twiki/bin/edit/Main/Virtual_mailbox_lock?topicparent=Main.ConfigurationVariables 401
1 64.242.88.10 /twiki/bin/edit/Main/Trigger_timeout?topicparent=Main.ConfigurationVariables 401
1 64.242.88.10 /twiki/bin/edit/Main/TWikiPreferences?topicparent=Main.WebHome 401
```

<br/>
Easy peasy. But wait! There's more! Head on over to the 
[Bash Analytics](https://github.com/relaxdiego/bash-analytics) repository
to get more examples.


NOTE: You can very easilly modify the processor to parse other log file formats
such as those from NGINX, Hadoop, k8s, etc.
