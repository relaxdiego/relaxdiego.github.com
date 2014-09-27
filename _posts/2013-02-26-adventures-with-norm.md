---
layout: post
title: Adventures With Norm
comments: true
categories: Programming, Ruby, QA, Compiler, Ragel, Racc
---
It's been [almost](/2012/04/using-cucumber.html) [a](/2012/04/on-cucumbers-opinionatedness.html) [year](/2012/05/how-we-use-cucumber-the-sequel.html) since I dived more deeply into automated requirements verification/QA while attempting to apply my new knowledge through a number of [Norm prototypes](https://github.com/norm-framework). It's been slow going, but very interesting thanks to a plethora of useful resources including [James Bach's site](http://www.satisfice.com/articles.shtml) and [This Freaking Awesome Book](http://createyourproglang.com/).

My biggest takeaway from this so far is that it's just not feasible to automate the verification of each and every requirement. No doubt it's possible, but there will be times when the benefits are overshadowed by the costs of automation. There are various reasons why this is so. Sometimes it's because there are some discrepancies that are hard to describe in writing, but you know it when you see it. In other times, it may be because you just don't know what the output will look like (e.g. a chart that displays some non-deterministic trend). There are many other reasons but that's not to say that automation has absolutely no place in those examples. For instance, we could automated the setup and teardown steps of a test case while leaving the body of said test case (or even just the verification step) to the human. And so this is what gave me new ideas that I might add to my next prototype:

1. Provide the test case writer the ability to indicate that one or more steps need to be manually done by a human. In such a case, when Norm reaches the manual step, it should pause and wait for a human to indicate whether the system being tested passed or failed.
1. When running in a CI environment, however, Norm should be smart enough and not wait for human input. Instead, it will take a snapshot (or a video clip??) of the UI and then let the human verify after the fact.

I have enough software development experience in me to not let the shortness of the above list fool me into thinking this is a simple implementation. The devil is always in the details which should make the next 12 months an even more interesting adventure!
