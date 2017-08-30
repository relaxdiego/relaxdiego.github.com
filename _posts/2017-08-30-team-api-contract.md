---
layout: post
title: A Team's API Contract
comments: true
categories: agile, working, teamwork, api
---

This is an old email that I sent to my teammates. I'm sharing this for
posterity and also because I think it applies to any software team.

---

Hi team!

I hope you’ve had a good week this week and, if not, well it’s a Friday!

I wanted to talk to you about the “API contract” between you and me
because it facilitates the team’s morale and productivity. Before I
proceed, I want you to fully understand that what I write below IS NOT
law. Instead, consider it as a conversation starter: “This is how I see
things. Tell me if it’s different from what you are seeing.”

Firstly, for the purpose of this email, let’s define “user requirements.”
Anything that affects our user’s experience is what I refer to when I say
“user requirements.” An obvious example of this is the stability of
Kubernetes after it’s been set up by our tool. A less obvious example
is all terminal interactions that the user would have with our tool's
components. Because our target users are DevOps Engineers, the bulk of
our tool's “UI” is not graphical so command-line arguments/options are
within the scope of “user requirements.” Still less obvious examples are
things that our users experience before they even start to use our tool.
That includes our project wiki and the download URLs in our package repo.
Perhaps even less obvious is the user’s experience after k8s has been
installed: should they find a problem as they use k8s, they will want
to quickly reach out to us for help and we should be able to quickly
pinpoint if our deployer is to blame and what version(s) of it.

So that’s how I understand “user requirements.” For the sake of brevity,
from this point onwards, I will just say “requirements.”

The obvious question then is: who decides if the requirements are correct?
That’s a very delicate balancing act because, on the one hand, I have to
take into consideration the feedback that I get from actual users. On
the other hand, I have to take into consideration the feasibility of
implementing the requirements (which is an insight I expect to receive
from you). The short answer is “it depends.” This is the first point of
integration between you and me and, at this point, I expect that you and
I will have some back and forth until we come to an acceptable
requirement definition.

We MUST have some back and forth because that’s the only way to get to
a decision that considers most, if not all, angles.

The next question is: given that we have come to an agreement on the
requirements, what is my expectation after that? Well, in my job as a
technical product manager in a previous life, my stance has always been
“These are the requirements. As long as you meet those requirements and
I can be assured that you’ve maintained an acceptable level of quality
and maintainability, I don't care how you satisfy said requirements.” I
continue to adopt that stance with our project.

That forms our “API contract.” If you feel I’m breaching said contract,
please do not hesitate to call me out on it. PM me or give me a call.
Whatever you think is the best way to get my attention. But you must let
me know. If it helps, picture me as a [dynamic control system](https://en.wikipedia.org/wiki/Control_theory#/media/File:Feedback_loop_with_descriptions.svg).
In that diagram, that sensor helps me to adjust my behavior accordingly.
However, that sensor isn’t pulling all the metrics all the time because
it can only do so much. It has support for “push metrics” though so in
cases where you think a critical metric is not being pulled, I will
count on you to actively push it.

So that’s it for now. Again, what I write above IS NOT written in stone.
It’s a napkin-based draft and I expect you to give me feedback if you
find something off. Whether you found that while reading this email or
days after you’ve read it, tell me regardless.

Please let me know that you’ve read this email by responding with an
“ACK.” If you want to add more to that ACK, you are very much welcome!

Happy Friday and [keep on rockin](https://www.youtube.com/watch?v=eaIvk1cSyG8)!

Regards,

Mark
