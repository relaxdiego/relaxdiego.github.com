---
layout: post
title: Canal and Calico Networking for k8s
comments: true
categories: k8s, kubernetes, canal, calico, networking
---

Here's a quick diagram on how Canal and Calico networking is implemented
in Kubernetes. If the image below is hard to read, [here's a direct link](https://docs.google.com/drawings/d/1vEMtzIzaXb7UFwfJJ5utEStqPw9cT3wQg3Tut1dP1a8/edit?usp=sharing).

<img src="https://docs.google.com/drawings/d/e/2PACX-1vQGTLNcWY-Tb7v2hOS5OxhMiWe7rUpB09n4Cb9ndigFBQUFjapWjInkMYk29Rp1XVK5E_Zj-Fyj4bg6/pub?w=1310&amp;h=1592">

NOTE: While I've depicted the iptables rules and routes as boxes in these
diagrams, note that they're not really implemented as Linux devices. Rather,
I just wanted to show how the routes are applied to the packets as they
make there way to and fro the actual devices.
