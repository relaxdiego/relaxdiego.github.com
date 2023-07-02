---
layout: post
title: A Case for Monorepos
comments: false
categories: programming, monorepo
---

For some time now, we've been living in the era of microservices. An era where
a strict separation of concerns is the norm. Where it is difficult to
circumvent the rule by way of putting each microservice in its own repository
and execution environment. This has, in many ways, permitted us to be more
thoughtful about our system designs, allowing us to avoid the "big ball of mud"
problem to a significant extent. However, this era of isolation has also
presented a unique set of challenges, specifically in the aspect of code reuse.

## Code Re-use Across Microservices

Conventional wisdom recommends the use of libraries in addressing the issue of
code reuse. Libraries shine when the aim is to encourage code reuse across
diverse groups or teams that have little interaction with each other. However,
libraries that are exclusively used by the same team can be more of an
unnecessary burden and, oftentimes, ineffective method of reducing code
duplication.

Because when you think about it in that context, libraries are just "code copypasta"
with extra steps. Bear with me for a moment:

### Code reuse via a library

1. Write common code in the library
2. Commit the change
3. Push to the repo
4. Wait for CI/CD pipeline
5. Update the version dependency in consuming microservice(s)
6. Import the module
7. Use the module/class/method

Compare that with:

### Code reuse via copypasta

1. Copy code from microservice A
2. Paste code to microservice B

No wonder copypasta is such an alluring, hard habit to break!

"But, Mark!" you might exclaim, "What about code maintenance? Wouldn't
libraries make that easier because you only have to change one place?"

That's true, but even then you'd still have to go through the same 7 steps to
distribute that change across your microservices. In some cases that won't even
happen just once for every fix/update. Sometimes, you'll introduce a change
that breaks one microservice so you'll likely have to go through the dreaded
7 steps--maybe multiple times--until all is well.

"You just need discipline," you might respond. Maybe, but when you're thinking
of multiple aspects of the code--more than likely, even in the case of
microservices--dealing with the 7 steps just to get your code to run becomes
the least of your concerns. So the path of least resistance wins and you just
promise yourself that you'll move the code to the library as soon as you have
time to spare.

{% highlight python llinenos %}
{% include code-snippets/case-for-monorepos/s01_todo.py %}
{% endhighlight %}

## Monorepo For Microservices

Using a monorepo project structure for a microservices deployment architecture
can address this problem. By locating each microservice's directoryalongside
each other in the same repo, you get the benefits of code reusability without
the arduous 7 steps.

```
.
├── Makefile
├── common
│   ├── pyproject.toml
│   └── ...
├── microservice_a
│   ├── pyproject.toml
│   └── ...
├── microservice_b
│   ├── pyproject.toml
│   └── ...
└── microservice_c
    ├── pyproject.toml
    └── ...
```

In this setup, you could have a top-level Makefile that takes care of
installing each microservice and the `common` library in editable mode in your
local machine so that changing the code is just a matter of saving and then
running the tests. Then, once you are happy with your changes, just push it
upstream and the CI/CD pipeline can test and deploy each microservice and the
common code.

In conclusion, the microservice era, despite its challenges, continues to
evolve. Traditional methods of code reuse, such as libraries, have proven
cumbersome within the same team, leading to the exploration of other approaches
like monorepos. Monorepos, with their streamlined workflow and simplified code
maintenance, represent a promising solution that leverages the benefits of code
reusability without the toil of the traditional steps. As we venture further
into this era, embracing such innovative strategies will help us to continue
reaping the benefits of microservices while effectively managing the
complexities they bring.
