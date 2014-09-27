---           
layout: post
title: All about the ECU
date: 2012-02-29 17:56:00 UTC
comments: false
categories: ECU definition, cloud computing, vCPU, AWS EC2 CPU
---

### What is an ECU?

ECU means "EC2 Compute Unit"

### OK, but what does it stand for?

First, let me explain what a VM is. A VM is defined by its:

* Processing power
* RAM, and
* Local storage

### What about ECU? 

Well, an ECU is just a unit of measurement for a VM's processing power and has nothing to do with RAM, or storage.


### Cool, but what does an ECU really mean??

OK, have a seat.

We'll get back to the ECU in a bit. First, let's talk about processing power. Now it's been historically problematic to communicate processing power to us mere mortals. Seriously, just ask AMD and Intel. For the longest time, they've been trying to compete for market share by touting their clock speed (that's the 'GHz' thing that you see in their marketing materials). But in reality, clock speed doesn't say it all. For example, a 1.2 Ghz Xeon processor released in 2007 actually has just as much processing power as a 1.7 Ghz Xeon processor released in early 2006. Furthermore a 2.0 GHz Pentium 4 performs just as much as a 1.7 GHz 2006 Xeon processor (Lost my reference on this. Will update this in the future when I find it). Comparing processors by their clock speed is probably like comparing cars by the speed of their engines' belts which doesn't mean much. So AMD and Intel eventually stopped competing based on clock speed.

### Still following me? Good.

So far we know that clock speed (aka GHz) does not tell you much about processing power, so we cannot rely on it exclusively. What we need to do is rely on clock speed AND instruction set architecture (32-bit vs 64-bit) AND CPU generation (because each generation introduces micro-architecture improvements that makes the CPU slightly more efficient).

Now here's the problem, because new CPUs are introduced every year, AWS will naturally end up with a cornucopia of physical machines with CPUs of different clock speed, instruction set architecture (it can happen), and CPU generation! So they had to come up with a unit of measurement for processing power that is fixed over time, otherwise, no two customers will get the right processing power for their money each time.

### Still there? Great.

So this is why they came up with the ECU. Take note of how they describe 1 ECU: "One EC2 Compute Unit provides the equivalent CPU capacity of a 1.0-1.2 GHz 2007 Opteron or 2007 Xeon processor."

  1.0-1.2 GHz = Clock speed

  2007 Opteron/2007 Xeon = IS architecture + CPU generation

### Great. How fast is 1 ECU?

OK, so here's where my own nose starts to bleed because I've been Googling for a standard way to measure processing power but, as it turns out it's not that simple. Because while it's clear that, when testing the CPU, you must avoid tests that will use components other than the CPU (avoid RAM, hard drive, GPU), how to actually test the CPU is another problem altogether. You can measure it via MIPs, or SPECint, or FLOPS. There's the geekbench, the John The Ripper test, TSCP, Unixbench, etc. Take your pick!

Once you've solved that issue, there's also the problem of finding benchmark results for a "1.0-1.2 GHz 2007 Opteron or 2007 Xeon processor" so that you can tell how much faster/slower your machine is compared to that!

### So where do we go from here?

Perhaps another day...