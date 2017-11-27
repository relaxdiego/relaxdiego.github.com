---
layout: post
title: Visualizing Brooks' Law
comments: false
categories: software engineering, project management, brooks law
---

"Adding human resources to a late software makes it later"
<br>-- [Fred Brooks](https://en.wikipedia.org/wiki/Fred_Brooks),
[The Mythical Man-Month](https://read.amazon.com/kp/embed?asin=B00B8USS14&preview=newtab&linkCode=kpe&ref_=cm_sw_r_kb_dp_yJ-gAb29R21FJ)

If you're like me, you'll find it hard to understand and, therefore,
manage the effects of Brooks' Law unless there's a model that visualizes
it for you. In this blog post, I attempt to provide such a visual model.

## The Components of Work

We can compute the relative progress of a team as follows:

> Percent Work Complete = (Completed Work) / (Total Work)

That's easy enough to grasp but there are a few things to consider to
obtain the dividend and divisor so let's break this equation down in
the next couple of sections.

## Completed Work

The thing to note about the first component, Completed Work, is that it's
not independent. That is, the amount of Completed Work is affected by
training effort that existing members have to provide to new team members.
Therefore, we can estimate Completed Work as follows:

> Completed Work = (Completed Work if Uninterrupted) - (Training Load on Team)

For the purpose of this discussion, let's designate "Completed Work if
Uninterrupted" as a constant with a value of 100. That is, if the team were
to work uninterrupted for a given period of time, they would be able
to finish 100 work items (In Scrum, this would be 100 stories but I'm
going to keep it generic since it can apply to non-scrum teams too).

As for "Training Load on Team," if we were to assume that 1 existing team
member will be assigned to each new team member and that the former needs
to spend half their time training the latter, we can compute it as follows:

> Training Load on Team = (New Team Members) * (1 Work Item)

That is, training one new team member is equivalent to 1 work item. If
the project had a high degree of complexity, however, then training
would be more than 1 work item.

## Total Work

We can estimate the divisor, Total Work, as follows:

> Total Work = (Original Work Items) + (Additional Coordination Required)

In this formula, we consider "Additional Coordination Required" as a set
of work items. Note how we don't have a component called "Existing Coordination
Required." To simplify the formula, we just lump that in with "Original
Work Items." We could have explicitly included it as a separate component
but since this whole exercise is really just a means to estimate rather
than accurately quantify "Total Work," this simplification will suffice.

Notice how we did not include "Training Load on Team" in this formula.
This is because we're only interested in the work that directly contributes
to the completion of the project.

## Additional Coordination Required

I'm discussing this component in its own section because this is the part
that can potentially have a significant effect on the whole formula and is
also the centerpiece of Fred Brooks' book. In that book, if we were to
represent a team as a graph, then the members would be the nodes and the
coordination that needs to happen between them would be the edges.

![Original Team Coordination](/assets/images/team-coordination-1.png)

Remember that the formula to compute the edges of a complete graph is

> Edges = Nodes * (Nodes - 1) / 2

Using the formula on our above example, we get 10 which is exactly equal
to the number of edges depicted in the diagram.

If we were to add 1 node to the above graph, that would add an additional
5 edges to the graph since the existing 5 nodes would have to connect to
this new one. Indeed, if we apply the same formula, we would get:

> 6 * (6 - 1) / 2 = 15

Remember though that we're only interested in the *Additional* edges
created by adding a new node. To get that, all we have to do is:

> Additional Edges = Total Edges - Original Edges

Therefore, to compute the Additional Coordination Required:

> Additional Coordination = Total Coordination - Original Coordination

And for each component, we just use the same formula to compute edges.

SIDENOTE: For this discussion, we consider the coordination that needs
to happen between any two members to be 1 work item. For complex projects,
This may be larger than 1 work item.

## Visualizing Brooks' Law With the Diagram of Effects

Now that we've broken down the components sufficiently, let's visualize
how one component affects the other using the Diagram of Effects as defined
by Gerald M. Weinberg in his book [Quality Software Management: Systems Thinking](http://a.co/1R0v4KB).

![Diagram of Effects: Percent Work Completed](/assets/images/diagram-of-effects-percent-work-completed.png)

From this graphic, we can deduce a few things:

1. Adding new members increases the load on the team which reduces
   the completed work
1. Adding new members also increases additional coordination which
   increases the total work
1. A reduction in the completed work also results in a reduction of
   the % work completed
1. An increase in total work reduces the % work completed

Based on the computation of each metric, we can tell right away that
"Additional Coordination" will have the biggest impact on % Work Completed
but it helps to present the effect graphically:


![Percent Work Completed](/assets/images/percent-work-completed.png)
<center>Scale of Additional Coordination work item was multipled by 10
to emphasize its non-linear relationship with % Work Completed</center>

<p>&nbsp;</p>

## Parting Thoughts

The point of this article was to show how increasing the number of members
can affect a team's progress. From what we've seen, the training load on
the team is not as big of a factor as the additional coordination needed.

I'll leave you now with a few questions as an exercise:

1. How should you control Additional Coordination such that it minimizes its
   effect on % Work Completed?
1. Can you utilize CI/CD as a minimization tool?

You may already have answers to these but if you want to get more insights,
I recommend the following resources:


* [The Mythical Man-Month](https://read.amazon.com/kp/embed?asin=B00B8USS14&preview=newtab&linkCode=kpe&ref_=cm_sw_r_kb_dp_yJ-gAb29R21FJ)
  by Fred Brooks
* [Quality Software Management: Systems Thinking](http://a.co/1R0v4KB) by Gerald M. Weinberg
* [Starting and Scaling DevOps in the Enterprise](http://a.co/0bm2mLr) by Gary Gruver
