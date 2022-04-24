---
layout: post
title: CI/CD and Environments
comments: false
categories: DevOps, CI/CD, Jenkins, queues, environments, dev, staging
---

Environments such as dev, QA, staging, and production are shared
resources and, like all other shared resources, access to them must be
managed; otherwise resource corruption may occur, resulting in lost
engineering time.

Take for example the following scenario where we have a pipeline
configuration that deploys to an environment:

![PE #1 deploys to environment](/assets/images/environment-sharing/deploy-1.png)

Let's also say that, as part of the pipeline execution, automated tests
are run against the just-deployed-to environment? Consider that these
types of tests tend to take more than a few seconds. Now what if, during
this same time, another pipeline execution is created:

![PE #2 is created](/assets/images/environment-sharing/deploy-2.png)

At this point, it's safe to say that the test results of "pipeline execution
(PE) #1" has become unreliable. We might even say that the results of
"pipeline execution (PE) #2" has also become unreliable. Ultimately,
this will result in engineers spending time on something that could've
been prevented.

> Even if you didn't have automated tests running against your environments,
> you will still have the problem of an unreliable pipeline because you have
> more than one PE's trying to modify the same environment.

## Naive Solution #1: Queue

Putting a queue in front of the environment is the most obvious solution.
Unfortunately, it’s not always the most optimal. Let's see what a queue
will do to our pipeline above. Given that PE #1 is already using the
environment, when PE #2 is created it then gets queued:

![PE #2 is enqueued](/assets/images/environment-sharing/deploy-3.png)

Automated tests against an environment are not instantaneous, so we have
to factor execution time into this scenario. If we say that the execution
time of the test is x, we can then say that PE #2 will have a wait time of 1x:

![PE #2 wait time](/assets/images/environment-sharing/deploy-4.png)

Now let's say that, within the period where PE #1 is still using the
environment, more PE's are enqueued. Given this, we will see that each
of these new PE's will have to wait by at least (number of items in queue
at enqueue time) * x:

![More PEs are queued](/assets/images/environment-sharing/deploy-5.png)

You can see how implementing a queue can be problematic: as the day
progresses, depending on how often a team integrates changes, their
pipeline will lag further and further. We need a better solution
than a queue.

## Naive Solution #2: Nightly Builds

I've seen teams fix the problem of a backed up queue by moving the
long-running jobs to a nightly build:

![Nightly builds](/assets/images/environment-sharing/deploy-6.png)

The problem with this approach is that, now, your main pipeline has lost
its reliability because it no longer performs a critical validation step.
A likely thing that will happen is that, before the team can be fully
confident in releasing to production, they will have to wait for the
results from the nightly build: a possible delay of, at most, 24 hours.

Alternatively, the team could manually trigger the environment tests which
solves the delay. However, because multiple commits may have been introduced
prior to this, it's possible that one or more test failures or errors have
been introduced. If the team is in a time crunch to deploy to production,
dealing with test failures at this time may not be their top priority.
This, again, leads to a reduction of the pipeline's reliability.

## Solution

Fortunately, this problem has been tackled by engineers before us and,
personally, I look to Jez Humble and David Farely via their book Continuous
Delivery for guidance.

![Continuous Delivery Book Cover](/assets/images/continuous-delivery-book-cover.jpg)

The solution that they provide is basically to put a stack, as opposed
to a queue, in front of the environment. Let's see this solution in action.
Recall that we have PE #1 that's currently using the environment so when
PE #2 gets created, it gets pushed to the environment's stack:

![Stack in front of an environment](/assets/images/environment-sharing/deploy-7.png)

Next, while PE #1 is still busy with the environment, more pipeline
executions are created and pushed to the stack:

![More PEs pushed to stack](/assets/images/environment-sharing/deploy-8.png)

Notice how the last pipeline execution to be pushed to the stack always
has a wait time of 1x whereas the older pipeline executions wait longer
the older they are.

The next question is: what should happen when PE #1 is done using the
environment? The obvious answer is to pop the latest item in the stack:

![Pop from the stack](/assets/images/environment-sharing/deploy-9.png)

The question has two parts though and the answer to this second part is
not so obvious: what do we do with the remaining items in the stack?

We could keep them but this would be a waste of computing resources since
PE #N already incorporates the changes to PE #3 and PE #2 so there's
no point in deploying and testing them. This suggests that we should 
discard the older PE's.

![Clear remaining items in stack](/assets/images/environment-sharing/deploy-10.png)

But what if a test failure/error was introduced by any of these older builds?
How would we determine whether it was introduced by PE #N or by any of
the older PE's? We could get fancy and perform a binary search to determine
which change introduced the error but the more important question is: does
it matter which PE introduced it? Most likely the answer is not and the
team's time is better spent just creating another pipeline execution that
fixes the problem!

## Concrete Example

Here's a demo of the above strategy. Unfortunately, this demo is old (Aug 2018)
and still uses Jenkins because I haven't been able to find the time to
update it to a more moden CI/CD system. It should still serve as a
useful example.

<center>
<iframe width="560" height="315" src="https://www.youtube.com/embed/5AuzogJfrpU" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>
</center>

Here are the basic parts to implementing a stack in Jenkins. Make
sure you've defined your stages the usual way. For example:


{%highlight groovy linenos%}
stage ('Automated Acceptance Tests'){
    steps {
        // Steps here
    }
}
{%endhighlight%}

So far nothing is different from the usual stage definition. Now let's
add the part that turns this stage into a stack. First, you'll need
to make sure that you've installed the [Lockable Resources Plugin](https://plugins.jenkins.io/lockable-resources).
What this plugin does is it gives your pipeline the ability to create
a cluster-wide "lock file." Once you have that installed, modify your
stage to look like the following:

{%highlight groovy linenos%}
stage ('Automated Acceptance Tests'){
    steps {
        lock(resource: "ProjectX-AAT") {
            // Steps here
        }
    }
}
{%endhighlight%}

In line 3, we added a lock() call which is a global function that becomes
available once you install the Lockable Resources Plugin. We then specify
the name of the "lockfile" that we want to acquire, "ProjectX-AAT" in this
case. Note that since the "lockfiles" created by Lockable Resources are
global or cluster-wide, you have to add some "scope" in the lock name to
avoid unnecessary contention with other projects that have nothing to do
with yours.

By default, the lock uses a queue. To use a stack, we set the
`inversePrecedence` option:

{%highlight groovy linenos%}
stage ('Automated Acceptance Tests'){
    steps {
        lock(resource: "ProjectX-AAT", inversePrecedence: true) {
            // Steps here
        }
    }
}
{%endhighlight%}

By adding `inversePrecedence: true` in line 3, we are telling Lockable
Resource to grant the lock to the last build that requested it. Now we
have our stack!

We're not quite done yet. While we've already implemented our stack
for our Automated Acceptance Tests stage, we still aren't able to cancel
older builds in the queue. In fact, at this point, with the code that we've
written thus far, once PE #4 is done with the AAT stage, PE #3 will
execute, then PE #2. What we want is for PEs 2 and 3 to be cancelled
as soon as PE #4 is popped.

To achieve this, we will need another Jenkins plugin called [Milestone](https://plugins.jenkins.io/pipeline-milestone-step).
This is the plugin that allows newer builds to cancel old builds. Let's
put it to use:


{%highlight groovy linenos%}
stage ('Automated Acceptance Tests'){
    steps {
        lock(resource: "ProjectX-AAT", inversePrecedence: true) {
            milestone 100
            // Steps here
        }
    }
}
{%endhighlight%}

In lines 3 and 5 we inserted the milestone keyword with some arbitrary
numeric value as an argument. What that line tells Jenkins is that
if there are any older builds that haven't passed this milestone, cancel
them. Let's do a walkthrough to clarify:

1. At time T, PE #1 occuppies the AAT stage. It will run for 10 minutes;
2. At time T+1, PE #2 enters the AAT stage and waits to acquire the
   lock for "ProjectX-AAT";
3. At time T+2, PE #3 enters the AAT stage. It also waits to acquire
   the lock for "ProjectX-AAT";
4. At time T+3, PE #4 enters the AAT stage. It waits to acquire the
   lock for "ProjectX-AAT";
5. At time T+4, PE #1 is done with the AAT stage;
6. At this same time, the lock for "ProjectX-AAT" is given to PE #4
   since it was the last to request it. This results in PE #4 passing
   milestone 100 which also cancels PE #2 and #3 since they have not
   passed that milestone yet.

## Summary

In this article, we learned about the problem of an unmanaged shared
environment and the downsides of queue-based and nightly-build-based
solutions. We also learned that the most optimal way to share an environment
without compromising the timeliness and reliability of a CI/CD pipeline
is to put a stack in front of it that discards older builds whenever
an item is popped.

If you want to know more about strategies to ensure a healthy CI/CD
pipeline, I highly recommend Jez Humble and David Farley's 
[Continuous Delivery book](https://www.goodreads.com/book/show/8686650-continuous-delivery).
