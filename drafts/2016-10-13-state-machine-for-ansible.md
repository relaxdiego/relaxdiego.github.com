---
layout: post
title: (Experimental) Building an Ansible Module as a State Machine
comments: true
categories: ansible, modules, configuration management, software development, automated testing, code coverage, agile, tdd, bdd
---

When it comes to implementing non-interactive processes, using state machines
has been one of my go-to designs for the simple reason that it's very good
at preventing flow/action spaghetti and, therefore, makes for a maintainable
codebase. 

What's even more awesome about it is that becuase the decision table (flow) is
located in a built-in data structure, it's very easy to graphically represent
it using Graphviz! Here's a sample of what that might look like:

[![](https://camo.githubusercontent.com/fd4da907613782c744fb2a0a44e8e790286a6a84/68747470733a2f2f646c2e64726f70626f7875736572636f6e74656e742e636f6d2f752f313335353739352f6d796d6f64756c652e706e67)](https://camo.githubusercontent.com/fd4da907613782c744fb2a0a44e8e790286a6a84/68747470733a2f2f646c2e64726f70626f7875736572636f6e74656e742e636f6d2f752f313335353739352f6d796d6f64756c652e706e67)

I've used state machines succesfully from automating spot instance bidding
in AWS, to automating my tennis court and campsite reservations. As I was
working on Ansible modules, I kept thinking about whether state machines would
also be a good fit.

Well, rather than keep wondering about it, I decided a few weeks back to
prototype it instead. Here's [the pull request that details it all](https://github.com/ansible/ansible/pull/17580). 
Looking forward to some feedback there!
