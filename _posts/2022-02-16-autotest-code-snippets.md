---
layout: post
title: Auto-testing code snippets in my blog
comments: false
categories: jekyll, python, bash
---

So I finally got around to auto-testing the code snippets in my blog posts.
As of today, the process of writing a blog post with code snippets goes
like this:


### Step 1: Run the background services

First I'll run [Foreman](https://ddollar.github.io/foreman/) locally while in my
blog's dir. Foreman starts up three processes in the background: a
[Jekyll](https://jekyllrb.com/) server, a resume autorenderer, and
a snippets autotester (the topic of this post). Each subprocess'
stdout and stderr are printed by Foreman, with each line properly prefixed
such that it says which process printed out which line:

<div class="terminal">
<pre>
<span class="proc1">21:01:04 blog.1</span>     | started with pid 88969
<span class="proc2">21:01:04 resume.1</span>   | started with pid 88970
<span class="proc3">21:01:04 snippets.1</span> | started with pid 88971
<span class="proc2">21:01:04 resume.1</span>   | make: Nothing to be done for 'resume'.
<span class="proc1">21:01:05 blog.1</span>     | Configuration file: /Users/mark/src/github.com/relaxdiego/relaxdiego.github.com/config.yml
<span class="proc1">21:01:05 blog.1</span>     |             Source: /Users/mark/src/github.com/relaxdiego/relaxdiego.github.com
<span class="proc1">21:01:05 blog.1</span>     |        Destination: /Users/mark/src/github.com/relaxdiego/relaxdiego.github.com/site
<span class="proc1">21:01:05 blog.1</span>     |  Incremental build: disabled. Enable with --incremental
<span class="proc1">21:01:05 blog.1</span>     |       Generating...
<span class="proc1">21:01:06 blog.1</span>     |                     done in 1.51 seconds.
<span class="proc1">21:01:06 blog.1</span>     |  Auto-regeneration: enabled for '/Users/mark/src/github.com/relaxdiego/relaxdiego.github.com'
<span class="proc1">21:01:07 blog.1</span>     |     Server address: http://127.0.0.1:4000
<span class="proc1">21:01:07 blog.1</span>     |   Server running... press ctrl-c to stop.
</pre>
</div>


### Step 2: Write a blog post

I then create a new file under my `_posts` directory, writing content in the
usual way except for the code snippet. For that part, I'm going to write an include
directive. For example, if I wanted to include a Python snippet in this
post, I'd write the following:

<div class="terminal">
{% raw %}
<pre>
{% highlight python linenos %}
{% include code-snippets/autotest-post/s01_hello_world.py %}
{% endhighlight %}
</pre>
{% endraw %}
</div>

That tells Jekyll to include the contents of `_includes/code-snippets/autotest-post/s01_hello_world.py`
inside this blog post when it renders it in HTML form. If I save the blog
post now, the `blog.1` subprocess would fail since the code snippet file
I want to include doesn't exist yet. So I'm not going to save it yet.


### Step 3: Create the test for the code snippet

Just because we're writing code snippets doesn't mean we abandon our
TDD principles. We're not savages! So then I'm going to write the test
for the snippet first and, for this example, it'll just be:

{% highlight python linenos %}
{% include code-snippets/autotest-post/s01_hello_world_test.py %}
{% endhighlight %}

When I save this file now, we're going to immediately see Foreman
spew a test failure in the terminal:

<div class="terminal">
<pre>
<span class="proc3">22:03:45 snippets.1</span> | Events: OwnerModified Created AttributeModified IsFile Updated
<span class="proc3">22:03:45 snippets.1</span> | Snippet: /\_includes/code-snippets/autotest-post/s01_hello_world_test.py
<span class="proc3">22:03:45 snippets.1</span> | Type: Python
<span class="proc3">22:03:45 snippets.1</span> | Tester: autotest-post/s01_hello_world_test.py
<span class="proc3">22:03:45 snippets.1</span> | pwd: /Users/mark/src/github.com/relaxdiego/relaxdiego.github.com
<span class="proc3">22:03:45 snippets.1</span> | + python /Users/mark/src/github.com/relaxdiego/relaxdiego.github.com/\_includes/code-snippets/autotest-post/s01_hello_world_test.py
<span class="proc3">22:03:45 snippets.1</span> | Hello world!
<span class="proc3">22:03:45 snippets.1</span> | Traceback (most recent call last):
<span class="proc3">22:03:45 snippets.1</span> |   File "/Users/mark/src/github.com/relaxdiego/relaxdiego.github.com/\_includes/code-snippets/autotest-post/s01_hello_world_test.py", line 1, in module
<span class="proc3">22:03:45 snippets.1</span> |     from s01_hello_world import hello_world
<span class="proc3">22:03:45 snippets.1</span> | ImportError: cannot import name 'hello_world' from 's01_hello_world' (/Users/mark/src/github.com/relaxdiego/relaxdiego.github.com/\_includes/code-snippets/autotest-post/s01_hello_world.py)
<span class="proc3">22:03:45 snippets.1</span> | <span class="proc3failed">FAILED</span>
</pre>
</div>

The key part of the error there is this: `ImportError: cannot import name 'hello_world' from 's01_hello_world'`
which makes sense because we've written the tests but we haven't written
the actual code that we're testing. TDD FTW, baby!


### Step 4: Create the snippet

Nothing else to do, right? I'm going to write the snippet file as follows:

{% highlight python linenos %}
{% include code-snippets/autotest-post/s01_hello_world.py %}
{% endhighlight %}

When we save that, we see this output from Foreman:

<div class="terminal">
<pre>
<span class="proc3">22:14:46 snippets.1</span> | Events: IsFile Renamed
<span class="proc3">22:14:46 snippets.1</span> | Snippet: /\_includes/code-snippets/autotest-post/s01_hello_world.py
<span class="proc3">22:14:46 snippets.1</span> | Type: Python
<span class="proc3">22:14:46 snippets.1</span> | Tester: autotest-post/s01_hello_world_test.py
<span class="proc3">22:14:46 snippets.1</span> | pwd: /Users/mark/src/github.com/relaxdiego/relaxdiego.github.com
<span class="proc3">22:14:46 snippets.1</span> | + python /Users/mark/src/github.com/relaxdiego/relaxdiego.github.com/\_includes/code-snippets/autotest-post/s01_hello_world_test.py
<span class="proc3">22:14:46 snippets.1</span> | <span class="proc3passed">PASSED</span>
</pre>
</div>

Sweeet!

At this point, when I save this blog post's `.md` file, Jekyll will happily
include the snippet file's contents into the rendered HTML, not knoweing or
even caring that the file was fully tested by our awesome setup. And that's
totally OK because I want to keeps things decoupled this way.


### Step 5 Run all tests as a final sweep

Just like the usual TDD workflow, I run all the snippet tests as a final
step before pushing my changes:

<div class="terminal">
<pre>
for snippettest in _includes/code-snippets/**/*_test.*; do script/test-snippet "$snippettest"; done
</pre>
</div>

Right now `script/test-snippet` only supports Python but nothing's stopping it
from supporting other languages down the line. It only takes a bit of my time
and energy.


## Talk is cheap. Show me the code!

Amen to that! Alright, if you want to see how this magic is done, you should
start with my [Procfile](https://github.com/relaxdiego/relaxdiego.github.com/blob/master/Procfile)
since that's what Foreman reads when it starts up. Check out the command that
gets executed by the `snippets` entry and then just fall into the rabbit hole
from there!

Enjoy. :-)

Oh and, of course, all code snippets in this blog post are available on
[Github](https://github.com/relaxdiego/relaxdiego.github.com/tree/master/_includes/code-snippets/autotest-post)!
