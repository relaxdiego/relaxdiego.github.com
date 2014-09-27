---
layout: post
title: Aviator now supports Keystone V3 authentication
comments: true
categories: Ruby, OpenStack, SDK, Aviator
---

I just recently merged a [significant change](https://github.com/aviator/aviator/pull/104)
to the master branch. This change now allows for authenticating against Keystone's V3 API.
That means that, as of right now, running the [create server](https://github.com/aviator/demo/blob/master/demo/create_server.rb)
demo using the following config file works as expected (must use bleeding-edge Aviator
from [HEAD of master](https://github.com/aviator/aviator/tree/master)).

<script src="https://gist.github.com/relaxdiego/324042ce68aa1065118f.js"></script>


## Override API version to use

You may have noticed that extra section at the bottom of the sample
config file above:

    compute_service:
      api_version: v2

That setting allows you to override Aviator's behavior and make sure that
you always use Nova's v2 API, even if API V3 is available alongside V2. In
fact, if more than one API version is available for a service, you will
need to specify which one you want to choose in the configuration file.

But what if you also want to use one request from Nova's V3 API? Not a problem.
You can override the API version to use in your call to the request:

    compute_service.request :something, :api_version => :v3 { ... }

## Understand Keystone API V3 authentication response format

Keystone API V3 vastly improved the way authentication is made but with it
a major change was introduced to the response it provided to clients. This
meant that all Aviator requests should be able to extract the data they need
regardless of format. This required a major overhaul of the core part of the
library due to some wrong assumptions about which part of the response to
keep and discard. Thanks to extensive automated tests, we were able to complete
it in one weekend and it didn't even require changing anything in the existing
request classes.

Special mention goes to [Stephen Paul Suarez](https://github.com/devpopol)
for laying out the initial work on this change. His merged work on the Keystone
V3 create token request is [here](https://github.com/relaxdiego/aviator/blob/65cde626bd2c232ec8987a506b7eb776e992a728/lib/aviator/openstack/identity/requests/v3/public/create_token.rb).

## A few internal reorganizations

This is only significant if you've been working on Aviator's code (and, hopefully,
you'll submit that work upstream soon!). I've removed some more Openstack-specific
code out of aviator/core and into aviator/openstack/provider.rb. This will make
that non-near-term plan of turning the Openstack part into a plug-in so that
Aviator core can support other cloud providers.

Another major change that's been done is that I've moved the request files to
their own subdirectory (requests/). This is in preparation for my plan of
creating higher-level resource objects (Server, Project, User, etc). Some initial
discussion for the design of that may be found [here](https://github.com/aviator/aviator/issues/71).

## What's Next

Aside from the the members of the [Musashi Dev Team](https://github.com/musashi-dev/aviator),
there's only me working on this and I only have time to work on it over the weekend.
This is why work on Neutron has not started. The rest of the request files for
Keystone V3 are also not there yet. Same with Compute V3. The work is actually fairly
simple. As you can see [here](https://github.com/aviator/aviator/blob/master/lib/aviator/openstack/compute/requests/v2/public/create_server.rb),
it's fairly simple to create a request file and its matching [test](https://github.com/aviator/aviator/blob/master/test/aviator/openstack/compute/requests/v2/public/create_server_test.rb).
However, because it's just me, and because there are a lot of request files to make,
progress is admitedly slow. I would really love to see some contributions in that area.
If you want to help, hit me up via email or in the comments below.
