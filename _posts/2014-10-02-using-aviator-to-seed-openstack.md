---
layout: post
title: Using Aviator to Seed OpenStack
comments: true
categories: OpenStack, Aviator, Installation
---

I added a change to Aviator so that you can use it to seed OpenStack. I had not thought
about this scenario when I built Aviator. The assumption from the get go was that it
will be used at that point in time when OpenStack has been installed and fully configured.
We were very lucky though that the changes needed to support this unexpected requirement were
very minimal. In fact, the changes were more syntactic sugar than anything else.
I'll get to that part in a bit. First, let's see how one might use Aviator to
seed OpenStack.

## Before: Initializing Aviator with the Service Token

The problem was that when you provide Aviator with a token to use for authentication,
it puts this in the request body which is the correct thing to do under normal
circumstances. However, service tokens can't be used that way because they're not
really associated with a user in Keystone. So you cannot authenticate like this:

{% highlight ruby linenos %}
openstack.authenticate do |params|
  params.token_id    = 'service-token-here'
  params.tenant_name = 'mytenant'
end
{% endhighlight %}

Instead, you would use it in the X-Auth-Token header directly. Before the
change, it was already possible to inject the service token in the header although
it wasn't documented since, again, I didn't expect it would be needed. Anyway,
here's how you would do it:

{% highlight ruby linenos %}
session_data = {
  :base_url => "BASEURLHERE"
  :body => {
    :access => {
      :token => {
        :id => "SERVICETOKENHERE"
      }
    }
  }
}

response = keystone.request(:create_tenant,
                            :api_version => :v2,
                            :session_data => session_data) do |params|
  params.name        = 'Tenant A'
  params.description = 'First Tenant!'
  params.enabled     = true
end

puts response.status
{% endhighlight %}

Essentially, by assigning the service token to `session_data[:body][:access][:token][:id]`,
you are tricking the [base OpenStack request class](https://github.com/aviator/aviator/blob/b51bf196cb8881073f2700959b6a8da6ad4bf5e9/lib/aviator/openstack/common/requests/v0/public/base.rb#L21)
in Aviator into thinking that it's already authenticated. Also, so that the base OpenStack request class knows where to send the request, we have to explicitly provide a `:base_url`. Under normal circumstances,
the `:base_url` would be provided to us by Keystone when we authenticate. But since we're
not authenticating at all in this case, we have to specify it ourself.

> SIDENOTE: Specifying the service endpoints (base_url) may seem like a red flag but
> it's not really a problem. Since we're bootstrapping OpenStack, we'd also be the
> ones who will be setting these service endpoints anyway! The trick is to not hardcode the
> base url but to pull it from the same data sources used to populate OpenStack itself.

So all is well and good from the get go! Except for one small thing that I couldn't
ignore:

{% highlight ruby linenos %}
session_data = {
  :base_url => "BASEURLHERE"
  :body => {
    :access => {
      :token => {
        :id => "SERVICETOKENHERE"
      }
    }
  }
}
{% endhighlight %}

That's just way too many levels for a single value! I decided we needed to change
that. After all, one of the reasons I wrote Aviator was so that I would have a simple
Ruby DSL for working against the OpenStack APIs.

## After: Initializing Aviator with the Service Token

And here's the new way of doing the above:

{% highlight ruby linenos %}
session_data = {
  :base_url      => 'http://example.com',
  :service_token => 'service-token-created-at-openstack-install-time'
}

response = keystone.request(:create_tenant,
                            :api_version => :v2,
                            :session_data => session_data) do |params|
  params.name        = 'Tenant A'
  params.description = 'First Tenant!'
  params.enabled     = true
end

puts response.status
{% endhighlight %}

That's it. All we did is simplify the DSL so that, instead of 7 lines of noise,
you have one line with the `:service_token` key and the actual service token.
It's not rocket science but I very much like how it makes the code more
readable.

> SIDENOTE: There was actually another change needed but that was just
> a one-line change so that the Session object will not require us to
> authenticate in order to get access to a Service object.

## The changes needed

Here are the changes needed:

* [First Change](https://github.com/aviator/aviator/pull/112/files) - This
  was the change to the Session object so that it didn't check for authentication.
  The significant change is in `lib/aviator/core/session.rb`. All other changes
  are either test updates or improvement in the error messages in case the
  calling code skipped authentication by mistake.
* [Main Change](https://github.com/aviator/aviator/pull/113/files) - Ignoring
  the test and the comments, that's really just a two line change!

Basically, just three lines to make it possible to use Aviator for bootstrapping
OpenStack!

## So What's the Takeaway?

I think that the simplicity of the required change is a testament to the
importance of spending time at the beginning of the project to learn about
the domain before writing a single line of code. Adding to that, even after
you've understood the domain, I believe it's just as important to validate
what you've learned through throw-away prototypes. If I hadn't done this with
Aviator, I would've been stuck [with this](https://github.com/relaxdiego/redstack)
which is not the best design from my point of view.

So now, while I started this article by talking about things specific to
one of my projects, I'd like to end it with some nuggets of advice that, I hope,
will be a useful reminder to any software engineer kind enough to read all the
way to this part of the article:

1. Don't jump straight to coding. Learn about the domain. Study the language
   or jargon of the domain. This is nothing new and has been advocated for
   some time now and wonderfully codified in [this book](http://books.google.com/books/about/Domain_Driven_Design.html?id=hHBf4YxMnWMC)
1. If you must jump straight to coding, make sure to jump into it with the mindset
   that you may have to throw it away after you've learned more things. In
   fact, the chances are close to 100% that you will have to throw it away
   to start writing the real thing!
1. Don't skip the Class, Responsibility, Collaborators (CRC) cards for
   describing your classes! Add one more to that card: the list of things
   that the class is NOT responsible for. I've found that this list is just
   as important as its counterpart.
1. Use diagrams. For me, the bare minimum is a high level [class diagram and
   sequence diagram](https://github.com/aviator/aviator/wiki). Your mileage
   may vary on this one but it helps me enormously since I'm a very visual
   person and need to doodle/draw before I can even begin talk about the
   code I'm about to write.

Happy coding!
