---
layout: post
title: (VIDEO) Easier Ansible Onboarding with Bootstrapper Kit
comments: false
categories: DevOps, Docker, Ansible, Onboarding, Makefile, Bash
---

So you've been given a greenfield project, on a totally fresh infrastructure.
How exciting! You whip out your Ansible Fu and start working on some playbooks
to bootstrap the cluster and off you go from 0 to 60 in 1.2 seconds!

But then, at some point, you realize you have to onboard incoming teammates.
You have to make sure the README is updated with all the dependencies they
need to install. Oh, and that you have to ping them anytime one of the dependencies
changes. That'll probably take up half of your day with all the confusion and
context switching.

And don't forget the seed secrets. You want to track them in version control
but you also want to make sure they're encrypted. So you use [Ansible Vault](https://docs.ansible.com/ansible/2.4/vault.html)
to encrypt those secrets. Problem solved! Except that you now have to share the
vault password (heaven forbid that's what you used) or the vault password file
with each teammate. How do you share it? Dropbox? IM? Email?

Ansible is great but bootstrapping a project has got to be easier than this.
Here's a proof-of-concept project that attempts to address the above inconveniences
with as little manual dependency installations as possible (Just Docker, Make, and Bash!)

<center>
<iframe width="560" height="315" src="https://www.youtube.com/embed/PweKPLDweO4" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
</center>

The repositories mentioned in the video are:

* [Bootstrapper Kit (Playbooks on steroids)](https://github.com/relaxdiego/bootstrapper-kit)
* [Sample Cluster Config Dirs](https://github.com/relaxdiego/bootstrapper-sample-clusters)
