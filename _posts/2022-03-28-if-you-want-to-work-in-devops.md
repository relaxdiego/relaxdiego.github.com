---
layout: post
title: If You Want to Work in DevOps
comments: false
categories: devops job responsibility operations ci/cd dx
---
If you’re hoping to land a job that has "DevOps" in the title,
understand that your overarching responsibility is to ensure that
the organization's software service delivery process is optimal and
that the availability of each service meets user expectations.

To achieve that, you must ensure that the infrastructure supporting
each service is robust. This is where your systems design skills come
into play.

...and, should a service or its infrastructure experience an unhandled
error, that you have instrumentation in place to let you know of it
immediately. This is what alerting is for.

...and, once you receive alerts, that you have tooling in place to help
you get to the root cause as quickly as possible. This is what metrics,
logs, dashboards, and automated runbooks are for.

...and, once the root cause is identified, that you have multiple
environments that the developers can use to experiment with potential fixes
before releasing any of them to production. This is what dev, QA,
and staging environments are for.

...and, during the above experimentation, that you have a single system
that is responsible for building and deploying code to the above
environments so that everyone is on the same page in terms of the state
of said code. Meaning: if this system can’t build or deploy the code,
everyone can quickly agree that something is broken and not get stuck at
arguing whether something is broken in the first place. This is part of
what CI/CD is for.

...and, also during experimentation, that there is tooling in place to
help developers get a better understanding of the codebase’s quality
so that they’ll know which parts to focus on. This is what coverage
reports, static analysis reports, security scan reports, and automated
test reports are for.

> **IMPORTANT**: These quality reports are for the engineer’s use and
> should not be utilized by managers to judge performance.

...and, also during experimentation, that the local development
experience is streamlined so that developers can get fast feedback
on their changes even before they push their code upstream. This is
the purpose of designing the service’s deployment architecture such
that it can be replicated in isolation locally.

A DevOps Engineer has a wide set of responsibilities to cover (the
above list is incomplete) but they all revolve around ensuring that
systems and processes are in place to help keep a software service
running as expected in production.

Good luck!

---

Postscript: This was originally posted on [LinkedIn](https://www.linkedin.com/posts/markmaglana_if-youre-hoping-to-land-a-job-that-has-activity-6900606649137029120-Wzvg?utm_source=linkedin_share&utm_medium=member_desktop_web).
