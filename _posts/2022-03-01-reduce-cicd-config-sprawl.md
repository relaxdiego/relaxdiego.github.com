---
layout: post
title: Reduce Your CI/CD Config Sprawl
comments: false
categories: CI/CD circleci confg orb dynamic config
social_preview_suffix: -cicd-config-sprawl
---

If you’re still experiencing the pain of CircleCI config.yml copypasta
even after using orbs, here’s a possible next step in your evolution.

<center>
<iframe width="560" height="315" src="https://www.youtube-nocookie.com/embed/4a7IRoDQMWI" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
</center>
<center>
NOTE: To comment on the video, please <a href="https://youtu.be/4a7IRoDQMWI">watch it on Youtube</a>
</center>

## Transcript

In CircleCI, your workflow configuration is stored alongside your code in
`.circleci/config.yml`. This makes it easier to synchronize your CI/CD
workflow with your code.

However, this also comes with disadvantages. For one, it can result in
duplicate workflow and job definitions. This is especially problematic
if you have multiple repositories that have the same workflow. For
example, let's say you have 3 distinct applications all written with the
FastAPI framework and deployed to Kubernetes. In this case you'd have to
make sure that their config files don't diverge from one another. Otherwise
you'll have to frequently re-learn how each application is built and
deployed.

A partial solution to this is to use CircleCI Orbs. With orbs, you can extract your job definitions from your config files and move them to a library (otherwise known as an orb). From there, your config files can simply use the jobs in that orb.

However, there's still the problem of duplicate workflow definitions because you haven't yet extracted your workflow definitions out of the config files. And you haven't done that because CircleCI Orbs don't support workflow definitions.

Now, you could solve this problem by writing some automation that synchronizes the config files across your 3 repositories. However, this would require a two-step process where the first step involves updating a workflow "template" and the second step involves running a script that renders the template into the config file of each repository. That second step can be tricky because you'd have to remember to do that for each active branch of each repository.

## Solution Overview
Wouldn't it be nice though if you could extract your workflow into a shared library so that the contents of each config file is reduced to just the things that are specific to each project?

Wouldn't it be nice if your config file simply contained something like this:

{% highlight yaml linenos %}
framework: fastapi
deployment_type: k8s
project_name: SampleApp1
{% endhighlight %}

...And, based on that, your workflow is dynamically generated?

As it turns out, you can approximate something like this by combining CircleCI's Orb feature with its Dynamic Configuration facility. What that means is you can end up with a config file that is very close to these fictitious examples and it would look something like this:

{% highlight yaml linenos %}
---
version: 2.1
setup: true
orbs:
  golden: relaxdiego/golden@1
workflows:
  setup:
    jobs:
    - golden/setup_fastapi_k8s:
        project_name: SampleApp1
{% endhighlight %}

In this config file, you'll notice that, in general, it's just like any other CircleCI config file except that:

Number 1: There is that `setup: true` line which is a valid CircleCI option that we'll get to later;

Number 2: It uses an orb named "golden"

Number 3: It uses just one job named {{setup_fastapi_k8s}}

Now let's say, for example, that we've defined a "FastAPI + Kubernetes" workflow template that includes the following jobs:

1. Run unit tests
1. Build the artifact
1. Deploy to dev environment
1. Run integration tests
1. Deploy to staging environment

In this case, all our 3 FastAPI repositories, by just creating this minimal config file, will automatically have this workflow. Even better is that, anytime this workflow template is upgraded to include more features (such as linting, coverage reporting, and Slack notifications), our 3 FastAPI projects will automatically inherit them without changing anything in their config file.

If that sounds like it could be for your team, keep watching.

## Solution

Now here's an important heads up before we continue: I'm going to assume that you're already familiar with CircleCI Orb development. If not, I recommend that you study the CircleCI Orb SDK so that you can make the most out of this video.

I should also note that links to the source code are provided in the description below.

Start with a sample app that contains a simple {{config.yml}} that defines the "unit test" and "build" jobs;

In the same config file, we'll also define the workflow that uses these jobs. When we push these changes, we'll get the following results in Circle CI.

Next, move the jobs to the golden orb which is in its own repository. We then reference it in the config file. When we push both changes, we will get the following report in Circle CI.

Next, we're going to extract the workflow from the config file and we're going to do that by creating a totally new job in the golden orb whose sole responsibility is to dynamically generate a config file. We'll call this job {{setup_fastapi_k8s}}.

You probably noticed how it uses BASH to render the config file. You're not limited to BASH. You can actually use any language. In my case, I've been able to use Python and Jinja2 successfully.

Now since we've extracted the workflow to the orb, we will now update the static config file in our sample app such that it uses the {{setup_fastapi_k8s}} job. When we push these latest changes, we'll get the following results in Circle CI.

Notice how two workflows have executed: the first one is our static config file and the second one is the dynamic config file that was generated from calling the {{setup_fastapi_k8s}} job.

From this point onwards, our workflow is centralized into the orb and any changes we make there will automatically be reflected in our sample app's workflow.

Let's see that in action: First we create a {{deploy_fastapi_k8s}} job in the golden orb and have {{setup_fastapi_k8s}} add it to the dynamic config.

Next, we will trigger the pipeline of the sample app. Without changing its config file, we can see that the {{deploy_fastapi_k8s}} job is now part of the workflow.

Next, let's add a parameter to the {{setup_fastapi_k8s}} job and name it {{project_name}} then modify the config file in the sample app to provide a value for the {{project_name}} parameter. When we push the changes, the workflow can automatically use this in its various jobs.

Finally, let's create a second sample app with the same {{config.yml}} as the first sample app but with the {{project_name}} modified. When we push the changes to sample app 2, we automatically get the same workflow used by sample app 1.

## Conclusion

At this point we have a central place where we can define our workflow template and we don't have to worry about updating the config file in each branch of each repository. This makes CI workflow management easier and also has the nice side-effect of encouraging standardization across repositories.

I hope you found this mini-tutorial useful. If you have any questions or comments, please don't hesitate to use the comments section below.

## References

1. Sample App 1: [https://github.com/evil-org/sample-app1](https://github.com/evil-org/sample-app1)
1. Sample App 2: [https://github.com/evil-org/sample-app2](https://github.com/evil-org/sample-app2)
1. Golden Orb Source: [https://github.com/evil-org/golden-orb](https://github.com/evil-org/golden-orb)
1. Golden Orb Page: [https://circleci.com/developer/orbs/orb/evil-org/golden](https://circleci.com/developer/orbs/orb/evil-org/golden)
1. Transcript: [https://relaxdiego.com/2022/03/reduce-cicd-config-sprawl.html](https://relaxdiego.com/2022/03/reduce-cicd-config-sprawl.html)
1. Slides: [https://bit.ly/reduce-config-sprawl](https://relaxdiego.com/2022/03/reduce-cicd-config-sprawl.html)
