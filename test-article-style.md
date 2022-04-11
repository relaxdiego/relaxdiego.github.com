---
layout: post
date: 1999-12-31
title: Article Style Test
comments: false
categories: style, test, do not publish
---

## Lorem ipsum dolor

Sit amet, consectetur adipiscing elit. Vestibulum eget tortor sapien ac tempor
eleifend, ultrices mauris eget, commodo massa. Nam ullamcorper elementum arcu,
eu dictum libero tincidunt et. Orci varius natoque penatibus et magnis dis
parturient montes, nascetur ridiculus mus. Curabitur arcu leo, ullamcorper at
augue id, tincidunt eleifend mauris. Morbi vestibulum eu purus a consequat.
Nunc sit amet interdum dui. Sed `sed aliquam leo`. Nam ac vehicula nunc. Curabitur
tempor tincidunt ex. Vestibulum accumsan, sapien ac tempor hendrerit, lacus odio
sollicitudin ex, sed ullamcorper ipsum dui pellentesque lectus.

Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus
mus. Suspendisse non molestie enim. Praesent et gravida ante. Nam semper ipsum
eros, vel `euismod mi posuere` commodo. Pellentesque ut ullamcorper nulla. Nam euismod,
nisl quis luctus lobortis, mi enim viverra enim, eget vulputate nibh purus at ex.
Quisque vel magna egestas, gravida nunc sit amet, luctus metus. Aliquam erat volutpat.
Maecenas accumsan urna id est interdum, quis scelerisque ante vehicula. Duis varius
dolor nec ante iaculis fermentum.

## Quisque vel magna egestas

Nam semper ipsum eros, vel euismod mi posuere commodo. Pellentesque ut ullamcorper
nulla. Nam euismod, nisl quis luctus lobortis, mi enim viverra enim, eget vulputate
nibh purus at ex. Quisque vel magna egestas, gravida nunc sit amet, luctus metus.
Aliquam erat volutpat. Maecenas accumsan urna id est interdum, quis scelerisque ante
vehicula.

1. Quisque vel dolor sed leo fringilla euismod;
1. Vivamus ultricies libero vestibulum dui euismod, eget gravida lorem interdum;
1. Vivamus feugiat mattis ipsum sed vulputate. Maecenas efficitur metus vitae
   urna eleifend, quis vulputate purus ultrices. Donec vestibulum congue justo,
   eu finibus augue fermentum id.
1. Ut varius tincidunt justo a convallis. Suspendisse elit eros, faucibus vel
   sem egestas, tempor blandit sem.

> Suspendisse non molestie enim. Praesent et gravida ante. Nam semper ipsum
> eros, `vel euismod mi` vosuere commodo. Pellentesque ut ullamcorper nulla. Nam euismod,
> nisl quis luctus lobortis, `mi enim` viverra enim, eget vulputate nibh purus at ex.

### Maecenas efficitur metus vitae

Nam semper ipsum eros, vel euismod mi posuere commodo. Pellentesque ut ullamcorper
nulla. Nam euismod, nisl quis luctus lobortis, mi enim viverra enim, eget vulputate
nibh purus at ex. Quisque vel magna egestas, gravida nunc sit amet, luctus metus.
Aliquam erat volutpat. Maecenas accumsan urna id est interdum, quis scelerisque ante
vehicula.

- Quisque vel dolor sed leo fringilla euismod;
- Vivamus ultricies libero vestibulum dui euismod, eget gravida lorem interdum;
- Vivamus feugiat mattis ipsum sed vulputate. Maecenas efficitur metus vitae
   urna eleifend, quis vulputate purus ultrices. Donec vestibulum congue justo,
   eu finibus augue fermentum id.
- Ut varius tincidunt justo a convallis. Suspendisse elit eros, faucibus vel
   sem egestas, tempor blandit sem.

Code snippet with line numbers:

{% highlight python linenos %}
mock_instance = mock_A.return_value
mock_instance.say_hello.return_value = "hello!"
{% endhighlight %}

Code snippet without line numbers:

> This is challenging to style because of the way the Rouge library
> renders code snippets without line numbers vs the way it renders
> snippets with line numbers.

{% highlight python %}
# Get a reference to the mock A instance
mock_instance = mock_A.return_value
# Now customize its behavior
mock_instance.say_hello.return_value = "hello!"
{% endhighlight %}

Code snippet using Markdown-style triple backticks

```
mock_instance = mock_A.return_value
mock_instance.say_hello.return_value = "hello!"
```

Code snippet with line numbers via include:

{% highlight python linenos %}
{% include code-snippets/autotest-post/s01_hello_world.py %}
{% endhighlight %}

Div with "terminal" class:

<div class="terminal">
<pre>
<span class="proc1">21:01:04 blog.1</span>     | started with pid 88969
<span class="proc2">21:01:04 resume.1</span>   | started with pid 88970
<span class="proc3">21:01:04 snippets.1</span> | started with pid 88971
</pre>
</div>

Code snippet with more than 10 lines:

{% highlight python linenos %}
mock_instance = mock_A.return_value
mock_instance.say_hello.return_value = "hello!"
mock_instance = mock_A.return_value
mock_instance = mock_A.return_value
mock_instance = mock_A.return_value
mock_instance = mock_A.return_value
mock_instance = mock_A.return_value
mock_instance.say_hello.return_value = "hello!"
mock_instance.say_hello.return_value = "hello!"
mock_instance.say_hello.return_value = "hello!"
mock_instance.say_hello.return_value = "hello!"
mock_instance.say_hello.return_value = "hello!"
{% endhighlight %}

YAML:

{% highlight yaml linenos %}
---
name: relaxdiego
description: Mark Maglana's Technical Blog
url: https://www.relaxdiego.com
enforce_ssl: www.relaxdiego.com
permalink: /:year/:month/:title.html
highlighter: rouge
markdown: kramdown
{% endhighlight %}

More Python:

{% highlight python linenos %}
# test_module2.py

from mock import patch
from module2 import B

class TestB:

    @patch('module2.A')
    def test_initialization(self, mock_A):
        # Mock A's do_something() method
        mock_A.do_something.return_value = True

        subject = B()

        # Check if B called A.do_something() correctly
        mock_A.do_something.assert_called_once_with('foo')
{% endhighlight %}

Ruby:

{% highlight ruby linenos %}
# From https://www.rubyguides.com/2019/02/ruby-code-examples/

def find_missing(sequence)
  consecutive = sequence.each_cons(2)
  differences = consecutive.map { |a,b| b - a }
  sequence = differences.max_by { |n| differences.count(n) }

  missing_between = consecutive.find { |a,b| (b - a) != sequence }

  missing_between.first + sequence
end

find_missing([2,4,6,10])
{% endhighlight %}
