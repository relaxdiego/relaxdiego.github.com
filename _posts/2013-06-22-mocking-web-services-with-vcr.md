---
layout: post
title: Mocking Web Services with VCR
comments: true
categories: software development, mocking, 3rd party services, automated testing, tdd, bdd
---
When writing applications or libraries on top of 3rd party web services, one often encounters connectivity problems ranging from slow to zero connection. Then there's the issue of rate limits where your machine can only make X number of requests per day. Any one of these issues is a killer on developer flow. Thankfully, numerous open-source tools abound that let you create a mock of a 3rd-party web service's API.

## Web Mocking Tools
I've tried a few mocking tools including [WebMock](https://rubygems.org/gems/webmock) and [RoboHydra](http://robohydra.org/). However, I needed a mocking tool that, unlike WebMock, didn't require me to handwrite the mocked response and, unlike RoboHydra, allows me to easily control its behavior from within my tests. This is what led me to the [VCR](https://github.com/vcr/vcr) gem. 

The idea is simple enough: you let VCR intercept your HTTP calls to the 3rd-party service, it will then record the details of the request and corresponding response in cassettes which are really just human-readable YAML files that it saves to disk. Subsequent matching requests will then receive this recorded response. What's cool about VCR is that you can dynamically tell it which cassette to save the transaction in and you can even specify how it matches requests (by uri, port, path, phase of the moon, time of day, your current weight, whatever!).

## Setting up VCR
VCR works with a number of Ruby HTTP libraries and setting it up is easy enough. In your test
helper (or spec helper if you're into Rspec), add the following:
 
    {% highlight ruby %}
    VCR.configure do |c|
      # Tell VCR where to save the cassettes (YAML files).
      # Absolute paths will work too.
      c.cassette_library_dir = 'fixtures/vcr_cassettes'
      
      # Tell VCR which HTTP library to 'intercept.'
      # I've been using Faraday lately.
      c.hook_into :faraday
    end{% endhighlight %} 

Next, surround your HTTP requests with `VCR.use_cassette`:

    {% highlight ruby %}
    # The 'users' parameter tells VCR to use the 
    # cassette at fixtures/vcr_cassettes/users.yml
    VCR.use_cassette('users') do
      # 'connection' is a Faraday Connection object
      response = connection.get '/users'
    end{% endhighlight %} 

In the above code, VCR will parse the request URL, header, and body and check the `users.yml` cassette if there is a matching request already recorded. If none, the request will continue to the 3rd-party service. VCR will then record the resulting response along with the request into the cassette. The next time this code runs, VCR will immediately return the recorded response instead of letting the request hit the 3rd-party service.

## Using VCR in an Existing Project
Setting up VCR in an existing project can be a pain in the ass but only if you have no choice but to go through your existing code and surround each HTTP request with `VCR.use_cassette.` Luckily, VCR has a nifty method that will save you from having to do that: `#around_http_request`.

    {% highlight ruby %}
    VCR.configure do |c|
      # Same setup as above.
      c.cassette_library_dir = 'fixtures/vcr_cassettes'
      c.hook_into :faraday
      
      # Tell VCR to use the 'users.yml' cassette for all
      # HTTP transactions happening in your code.
      c.around_http_request do |request|
        VCR.use_cassette('users', &request)
      end
    end{% endhighlight %}

But what if you only wanted to use VCR for certain types of requests? Easy enough, just pass in a lambda (anonymous function) to `#around_http_request` as its first parameter:

    {% highlight ruby %}
    VCR.configure do |c|
      # Same setup as above.
      c.cassette_library_dir = 'fixtures/vcr_cassettes'
      c.hook_into :faraday
  
      # Same as above, but with added lamda
      c.around_http_request(lambda { |request| request.uri =~ /api.twitter.com/}) do |request|
        VCR.use_cassette('users', &request)
      end
    end{% endhighlight %}

In the above code, I passed an anonymous function `lambda { |request| request.uri =~ /api.twitter.com/}` which expects a [Request](https://github.com/vcr/vcr/blob/ba820c65ec58cc918fef1bf897afbbbe0dc2b750/lib/vcr/structs.rb#L190) object that has methods such as `#uri` and `#parsed_uri`. Use the Request object's methods to determine if you should return true (which tells VCR to record the request) or false (which tells VCR to NOT record the request).

## Dynamically Organizing Cassettes
There are certain cases where you want fine-grained control on how to organize your cassettes and this is very easy to accomplish with VCR by dynamically generating the first parameter for `#use_cassette`:

    {% highlight ruby %}
    VCR.configure do |c|
      # Same setup as above.
      c.cassette_library_dir = 'fixtures/vcr_cassettes'
      c.hook_into :faraday

      # Call a method, instead of providing the 'users' string
      c.around_http_request do |request|
        VCR.use_cassette(get_cassette_path(request), &request)
      end
    end{% endhighlight %}

In the above example, `get_cassette_path` might check the `request` object to see if it's using v1 or v2 of the 3rd-party's API. Depending on that, it might return the string 'users/v1' or 'users/v2' which VCR will take to mean 'fixtures/vcr_cassettes/users/v1.yml' and 'fixtures/vcr_cassettes/users/v2.yml' respectively. Because you can use the request object to check the method, uri, path, header, and body of the request, there are plenty of ways to organize your cassettes.

## Teaching VCR How to Match Requests
By default, VCR checks the request's method (GET, POST, PUT, DELETE) and uri to determine which response to return to your application. For some requests, this default will do. For others, it won't. Consider the following requests:

    POST http://someservice.com/v2.0/tokens
    body:
      encoding: UTF-8
      string: "username":"user1","password":"passwordz"
      
    POST http://someservice.com/v2.0/tokens
    body:
      encoding: UTF-8
      string: "username":"user2","password":"icanhaztoken"

Based on the method and URI, they are exactly the same and VCR will always return the top one regardless of what you put in the body. Fortunately, there's a way for you to tell VCR how to match requests:

    {% highlight ruby %}
    VCR.configure do |c|
      # Same setup as above.
      c.cassette_library_dir = 'fixtures/vcr_cassettes'
      c.hook_into :faraday

      # Mostly the same as above except for the
      # match_requests_on parameter
      c.around_http_request do |request|
        VCR.use_cassette('users', match_requests_on: [:method, :uri, :body], &request)
      end
    end{% endhighlight %}

The built-in matchers are `:method`, `:uri`, `:body`, `:headers`, `:host`, `:path`, and `:query` and you can even define your own:

    {% highlight ruby %}
    VCR.configure do |c|
      # Same setup as above.
      c.cassette_library_dir = 'fixtures/vcr_cassettes'
      c.hook_into :faraday

      # Create a custom matcher called :port
      c.register_request_matcher :port do |r1, r2|
        r1.parsed_uri.port == r2.parsed_uri.port
      end

      # Use your custom matcher below.
      c.around_http_request do |request|
        VCR.use_cassette('users', match_requests_on: [:method, :port, :path, :body], &request)
      end
    end{% endhighlight %}

## Some Use Case Caveats
VCR is a very useful gem and I'm very impressed at how well thought out its API is. Over the course of my using it, however, I found some limitations which I have not totally found a workaround for:

**Cassettes can get stale.** Let's say that I wrote tests for logging in to the 3rd-party service today. Running this test will tell VCR to record an HTTP transaction with the response body containing a session token. A day later, I create a test for doing some operation on the service that requires a valid token. The login part of this new test will be matched by VCR with the old login transaction which contains a possibly expired token. When the main part of this new test proceeds, the HTTP request will hit the 3rd party service since VCR has not yet recorded this kind of transaction. The service will then respond with a "token not found" error. The fix here is simple: delete all cassettes. That's easy enough, but the big problem happens before that since this kind of error can be hard to diagnose because it will seem like the problem is with the 3rd-party service or your code when it really is just caused by stale cassettes.

**3rd-party's State Never Changes.** Let's say we managed to get the "complete set" of cassettes for the 3rd-party service thereby eliminating the stale cassette problem, we'd still have an issue because now we will never get past that starting state. Consider the test for deleting a user. This test will generally involve the following steps: 1) delete user, 2) check if the user was actually deleted. Step #2 will fail because VCR will return a recorded transaction where that user was still present. A possible solution could be to use one set of cassettes before user deletion and then switch to a different cassette immediately after deletion. This might help although I have yet to try it.

## In Closing
As mentioned above, I'm very impressed by the design of VCR and how easy it is to use and customize. The limitations above are not showstoppers and I hope to find elegant solutions for them soon. I'm thinking I just need to RTFM some more. Kudos to [myronmarston](http://myronmars.to/n/dev-blog) for creating this gem and making it open source!
