---
layout: post
title: Automated Testing, Organizational Learning, and Thermostats
comments: true
categories: Software, Testing, Knowledge
---

Agile software development is oftentimes touted as being a faster and more
efficient way of delivering software, as a way to reduce time to market, and as
a means to quickly respond to constantly changing requirements. That's all well
and good until the message is misunderstood to mean "let's skip documentation
and testing and just fix things as we go so that we can deliver within the
arbitrarily set deadline." That's not to say that Agile is no good. Rather, it's
to point out that the need for software development speed must be tempered by
the need to retain organizational learning.



## Anatomy of a Dynamic System

Dynamic systems typically have an input, a controller, and an output. That is,
you tell the system the desired output and it will perform a series of internal
operations to make that happen. Modern dynamic systems, however, have a crucial
component that makes it more effective: the feedback loop.

<img src="http://upload.wikimedia.org/wikipedia/commons/2/24/Feedback_loop_with_descriptions.svg"/>
<center>Source: http://en.wikipedia.org/wiki/Control_theory</center><br/>

The feedback loop captures information about the external environment and feeds
that back to the system which uses that information to regulate itself. To put
this in more concrete terms, let's look at a heating system's feedback mechanism:
the thermostat.

<img src="http://upload.wikimedia.org/wikipedia/commons/5/53/WPThermostat_new.jpg"/>
<center>Source: http://en.wikipedia.org/wiki/Thermostat</center><br/>

To raise the room temperature, you'd slide (1) to the right. This makes (2) turn
clockwise which, in turn, moves (4) to the right. Notice that (4) is connected to
the wire marked (3) which is one end of the circuit. Move (1) to the right just
enough and (4) will make contact with (5) which is the other end of the circuit.
This closes the circuit and fires up the heater.

The feedback loop in this case is the bimetallic strip that's wound into a coil
surrounding (2). Yes, in this case, the feedback loop is literally a loop! This
coil is continually collecting information about the environment (specifically,
the room's temperature) and feeding it back to the system. When the room heats
up, the coil unwinds, moving (4) slowly to the left. Uncoil enough and (4) will
detach from (5) turning off the heater. As the room cools down, the coil winds
back, moving (4) to the right until it touches (5) turning the heater back on.

What does this have to do with agile software development? Everything because
software development processes are dynamic systems too: the customer's requirements
are the inputs, the software design and development activities are the processes,
and the software is the output. It also has a feedback loop that contains more
information than a thermostat would (user feedback, bugs, etc.)



## Waterfall Revisited

A typical waterfall process is commonly understood as having the following phases:

<img src="http://upload.wikimedia.org/wikipedia/commons/e/e2/Waterfall_model.svg"/>
<center>Source: http://en.wikipedia.org/wiki/Waterfall_model</center><br/>

What is clearly absent from the waterfall model is the critical feedback loop
that would have allowed it to respond to new knowledge learned along the way.
Waterfall software development is like a heating system without a thermostat.
It's bound to burn the team and the customer in the end.

To be somewhat fair to the waterfall methodology, however, a feedback loop is
possible but it tends to be so late in the process (verification phase) that
it's virtually worthless.



## "Agile" Software Development

Agile's promise is to deliver correct solutions sooner by essentially slicing
major phases of the waterfall methodology and iterating through them in sprints.
When you think about it, these sprints are really mini-waterfalls with the demos
at the end serving as the output and also the source of the feedback loop. The
advantage here is that because the feedback loop happens sooner and more often,
it is more actionable and useful. However, if the knowledge learned in each
sprint is not codified in any way, then that feedback loop is anemic at best
because people forget, team members get re-assigned, employees move on, and
organizational knowledge is lost.

You'll often hear or directly experience these kinds of "agile" team environments
where they start out delivering software very quickly but then get mired by
difficult bugs or an inflexible architecture. These types of teams often hold the
banner of agile but skimp on automated tests and some form of documentation to
save time.



## Agile Software Development

True agile teams take full advantage of the feedback loop that the process
offers. One of the ways that they do this is by codifying knowedge via automated
tests that remain relevant throughout the project. It is through these activities
that a team is able to sustain its velocity and success. If you find that your
team is unable to consistently deliver, check your feedback loop. Chances are
it's not been given the respect and attention that it needs.
