---
layout: post
title: Mocking Objects in Python
comments: true
categories: software development, continuous testing, automated testing, tdd, bdd, python
---

For this post, I talk about mocking objects in Python. As a Rubyist, this one
was initially confusing especially since I was not yet familiar with Python's
package import magic.

## Importing Packages and Objects (A Review)

_You need to understand this part before you can effectively mock objects in Python._

Say you have a file named `my_package1.py` with the following code:

{% highlight python linenos %}
class A(object):

    def __init__(self):
      ...
{% endhighlight %}


Now say you want to import that in `my_package2.py` as follows:

{% highlight python linenos %}
from my_package1 import A

class B(object):

    def __init__(self):
        ...
{% endhighlight %}

What that first line in `my_package2.py` effectively does is create a variable
named `A` under the `my_package2` namespace that points to the actual `A` class
in memory. So now we have two variables pointing to the same memory address
and their fully qualified names are `my_package1.A` and `my_package2.A`.

    my_package1.A --|
                    |---> <Actual A Class>
    my_package2.A --|

Now let's say in `my_package2`, you use an unqualified `A` like the following:

{% highlight python linenos %}
class B(object):

    def __init__(self):
        self.a = A()
{% endhighlight %}

Behind the scenes, the interpreter will attempt to find an `A` variable in the
`my_package2` namespace, find it there and use that to get to the class in
memory. So the code inside `my_package2.py` is effectively using the
`my_package2.A` variable.

Now we're ready to mock objects.

## Mocking Objects

Once you understand how importing and namespacing in Python works, the rest
(well, most of it) is straightforward. Let's say you want to test `B` so you
then write a test for it as follows:

{% highlight python linenos %}
from my_package2 import B

class TestB:

    def test_initialization(self):
        subject = B()
{% endhighlight %}

Now let's say we want to focus our test on `B` and just mock out `A`. What we need
to do is mock out `my_package2.A` since that's what all unqualified `A`s will
resolve to inside `my_package2`. To mock out that variable, we use the patch
decorator:

{% highlight python linenos %}
from mock import patch
from my_package2 import B

class TestB:

    @patch('my_package2.A')
    def test_initialization(self, mock_A):
        subject = B()
{% endhighlight %}

There's a lot happening in the above code so let's break it down:

  1. `from mock import patch` makes the `patch` decorator available in this namespace
  1. In line 6, whe use the `patch` decorator to replace the memory address that `my_package2.A`
     points to. This new memory address contains an instance of the `Mock` class.
  1. Another side effect of our `patch` decorator is that our `test_initialization` method
     will receive an extra parameter which is a reference to the same `Mock` instance created
     in the previous step. This is why we have an additional parameter `mock_A` in there.

Reusing our diagram from above, the end result is this:

    my_package1.A ------> <Actual A Class>

    my_package2.A --|
                    |---> <Mock object pretending to be the A class. Impostor!>
    mock_A ---------|

Now, within `test_initialization`, you can use the `mock_A` variable to describe
how the mocked `A` should behave and you can even make assertions on it. For
example:

{% highlight python linenos %}
from mock import patch
from my_package2 import B

class TestB:

    @patch('my_package2.A')
    def test_initialization(self, mock_A):
        # Mock A's do_something method
        mock_A.do_something.return_value = True

        subject = B()

        # Check if B called A.do_something() correctly
        mock_A.do_something.assert_called_once_with('foo')
{% endhighlight %}

Go read more about Mock in [this extensive online reference](http://www.voidspace.org.uk/python/mock/).
Then come back for some tips on mocking attributes vs. methods.

## Tips on Mocking Attributes and Methods

If you want to mock an attribute or property, and you don't care about how
many times it was called (usually, you don't), just mock it like so:

{% highlight python linenos %}
  mock_A.some_attribute = 'somevalue'
{% endhighlight %}

### Mocking the mocked class' instance

When the subject under test calls mock_A's supposed constructor, it will
return another Mock object. This new Mock object poses as an instance
of the mocked A class. If you want to make changes to this mocked instance,
use `mock_A`'s return value:

{% highlight python linenos %}
mock_instance = mock_A.return_value
mock_instance.say_hello.return_value = "hello!"

subject = B()

# Make assertions on mock_instance and mock_A here
{% endhighlight %}

### Returning different values for each call

But what if you want the mocked method to return "hello" on the first call and
then "olleh!" in the second call (assuming the code under test calls it twice).
You can mock it like so:

{% highlight python linenos %}
mock_instance.say_hello.side_effect = ["hello!", "olleh!"]
{% endhighlight %}

Note how we're using `side_effect` here instead of `return_value`. You can also
assign a function to `side_effect` but so far I've been able to avoid that
complication by just using a list of return values.

### Danger: mocking non-existent attributes

One of the gotchas of mocking is that you might end up with behavior that's
specified in the mock object, but not really implemented in the real object.
The result is that you have unit tests that pass but integration tests that
fail. This is easily fixed but prevention is way better. That's why I make use
of the `autospec` feature:

{% highlight python linenos %}
from mock import patch
from my_package2 import B

class TestB:

    @patch('my_package2.A', autospec=True)
    def test_initialization(self, mock_A):
        # Mock A here

        subject = B()

        # Check calls to A here
{% endhighlight %}

The effect here is that mock_A will have the same signature (methods,
properties, etc) as the actual A class and you can't mock any attributes
on mock_A that isn't already defined in the actual class.

### Interrogating the mocked class/object

Remember that you can interrogate the mock objects and make assertions on
how many times their methods were called and even how they were called. Read
more about that [here](http://www.voidspace.org.uk/python/mock/mock.html#mock.Mock.assert_called_with).

That's it for now. Live long and prosper in your tests!
