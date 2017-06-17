---
layout: post
title: Writing Ansible Modules Complete With Tests
comments: true
categories: ansible, modules, configuration management, software development, automated testing, code coverage, agile, tdd, bdd
---
<sup>Co-Written by [Andreas Hubert](https://github.com/peshay)</sup>

While writing my first ansible module, I noticed that there wasn't any resource
that completely described how to get started on my local dev environment.
This article documents the steps that I took to get up and running. Hopefully
it will be a helpful resource for you too.

I should mention though that the following resources helped me get started
quickly in certain aspects. So a big thanks to the these folks! This article
builds on the foundations that they've started.

- [Unit Testing Ansible Modules](http://linuxsimba.com/unit_testing_ansible_modules_part_1)
- [Module Development Page](http://docs.ansible.com/ansible/developing_modules.html#testing-modules)
- [Matt Clay](https://github.com/mattclay), [John Barker](https://github.com/gundalow),
  [Toshio Kuratomi](https://github.com/abadger), [Brian Coca](https://github.com/bcoca),
  [Tim Rupp](https://github.com/caphrim007), [Allen Sanabria](https://github.com/linuxdynasty),
  and the rest of the folks at #ansible-devel for giving me valuable feedback!

## Sidebar: If You See Any Errors in This Doc

Please don't hesitate to [file a bug](https://github.com/relaxdiego/relaxdiego.github.com/issues)
at my website's Github repo. Feel free to submit a pull request too if
you like!

## Contents

1. [Preparing Your Environment](/2016/09/writing-ansible-modules-001.html)
1. [Write Your First Module](/2016/09/writing-ansible-modules-002.html)
1. [Complete the Module](/2016/09/writing-ansible-modules-003.html)
1. [Submitting Code Upstream](/2016/09/writing-ansible-modules-004.html)
1. [Helpful Resources](/2016/10/writing-ansible-modules-005.html)
