---
layout: post
title: Analyzing an Apache Log File with Bash and Friends
comments: false
categories: DevOps, Docker, Apache, Makefile, Bash
---

Pop quiz, hot shot! You need to quickly get an idea of the top 5 requests
grouped by requesting client between 6PM and 7PM that got a 40x HTTP status
code. Quick! What tools do you pick up? Do you use go, python, C? What
about the framework? How do you get the rest of your team to quickly use
it too?

OK slow down now and take a deep breath. For this instance, you don't need
anything more than Bash and friends. For instance, you could just run a
60-liner bash script to get the data I mentioned in the first paragraph above.

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
