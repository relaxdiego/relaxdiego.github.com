---
layout: post
title: Mocking Objects in Python
comments: true
categories: software development, continuous testing, automated testing, tdd, bdd, python
---

Mocking in Python can be initially confusing and [the official docs](https://docs.python.org/3/library/unittest.mock.html),
while informative, don't make it any less confusing for newcomers. In my case, I came across
it when I was just transitioning from Ruby which, I believe, contributed to the confusion.
This article takes a gentler approach to mocking so that you can get productive with it sooner.

## Importing Objects: A Review

The [unittest.mock](https://docs.python.org/3/library/unittest.mock.html) library builds
on top of how Python implements [the import statement](https://docs.python.org/3/reference/import.html)
so it's imperative that we have a solid understanding of this process before we can continue.

Let's say we have a file named `module1.py` with the following code:

{% highlight python linenos %}
# module1.py

class A(object):

    def __init__(self):
      ...
{% endhighlight %}

And let's also say we have a file named `module2.py` with the following code:

{% highlight python linenos %}
# module2.py

from module1 import A

class B(object):

    def __init__(self):
        ...
{% endhighlight %}

If you look at `module2.py` line 3, what it's effectively doing is that it's
creating a new variable named `A` that is local to `module2` and this variable
points to the actual `A` class in memory as defined by `module1`.

What this means is that we now have two variables pointing to the same memory
address. These two variables are named `module1.A` and `module2.A`:

```
               |------------------|
module1.A ---> |                  |
               | <Actual A Class> |
module2.A ---> |                  |
               |------------------|
```

Now let's say that, in `module2`, we used an unqualified `A` as in line 9
of the following:

{% highlight python linenos %}
# module2.py

from module1 import A

class B(object):

    def __init__(self):
        # Using "A" without specifying from which module
        self.a = A()
{% endhighlight %}

Behind the scenes, Python will try to find an `A` variable in the `module2` namespace.
After finding the variable, it then uses it to get to the actual `A` class in memory.
Effectively, the `A()` in line 9 above is shorthand for `module2.A()`.

## Mocking Objects

Building on top of what we learned in the previous section, let's say we want
to test our class `B` from above. We would then write our test initially as follows:

{% highlight python linenos %}
# test_module2.py

from module2 import B

class TestB:

    def test_initialization(self):
        subject = B()
{% endhighlight %}

Now let's say we want to focus our test on the logic of `B` and not care about
the internals of `A` for now. To do that, we need to mock out the variable
`module2.A` since that's what all unqualified `A`'s in `module2` will resolve to.

To mock out all unqualified `A`'s in `module2`, we use the patch decorator as
in line 8 below:

{% highlight python linenos %}
# test_module2.py

from mock import patch
from module2 import B

class TestB:

    @patch('module2.A')
    def test_initialization(self, mock_A):
        subject = B()
{% endhighlight %}

There's a lot happening above so let's break it down:

1. Line 3: `from mock import patch` makes the [patch decorator](https://docs.python.org/3/library/unittest.mock.html#unittest.mock.patch)
   available to our tests.
1. Line 8: Using the [patch decorator](https://docs.python.org/3/library/unittest.mock.html#unittest.mock.patch),
   we create an instance of [Mock](https://docs.python.org/3/library/unittest.mock.html#unittest.mock.Mock)
   and make the variable `module2.A` point to this instance.

Reusing our diagram from above, our new reality is as follows:

```
               |------------------|
module1.A ---> | <Actual A Class> |
               |------------------|

               |------------------|
module2.A ---> |      <Mock>      |
               |------------------|
```

Our use of the `patch` decorator above has another side effect. Namely
that this decorator provides our test method with a reference to the Mock
instance it created. We capture this reference using the `mock_A` parameter
in line 9.

So a more complete representation of our new reality is as follows:

```
               |------------------|
module1.A ---> | <Actual A Class> |
               |------------------|

               |------------------|
module2.A ---> |                  |
               |      <Mock>      |
   mock_A ---> |                  |
               |------------------|
```

> Note that since we are patching `module2.A` via the decorator method,
> this new reality is effective within the context of the `test_initialization()`
> method only.

With that, we can now use `mock_A` to describe how our mock `A` class should
behave:

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

And that's it! You now have the basics of mocking in Python. To dive
deeper, visit [the official documentation unittest.mock](https://docs.python.org/3/library/unittest.mock.html#module-unittest.mock).

## Tips on Mocking Attributes and Methods

### Stubbing Attributes

If you want to mock an attribute or property and you don't care about how
many times it was called (usually, you don't), just stub it like so:

{% highlight python linenos %}
mock_A.some_attribute = 'somevalue'
{% endhighlight %}

### Mocking Instances

When the subject under test (SUT) attempts to instantiate an object from
our Mock `A` class above, another Mock object is created and returned. This
new Mock object pretends to be an instance of `A`. If you want to customize
how this mock instance of `A` behaves, first get a reference to it via
the `return_value` attribute:

{% highlight python linenos %}
# Get a reference to the mock A instance
mock_instance = mock_A.return_value

# Now customize its behavior
mock_instance.say_hello.return_value = "hello!"

# Exercise the SUT
subject = B()

# Make assertions against the mock instance
mock_instance.say_hello.assert_called_once_with('foo')
{% endhighlight %}

### Returning Different Values

Now what if you want the mocked method to return "hello" on the first call and
then "olleh!" in the second call (assuming the SUT calls it twice).
You can mock it like so:

{% highlight python linenos %}
# Get a reference to the mock A instance
mock_instance = mock_A.return_value

# Now customize its behavior
mock_instance.say_hello.side_effect = ["hello!", "olleh!"]

...
{% endhighlight %}

Note how we're using `side_effect` in line 5 instead of `return_value`. You can also
assign a function to `side_effect` but so far I've been able to avoid that
complication by just using a list of return values.

### Avoiding Phantom Mocks

One of the gotchas of mocking is that you might end up with behavior that's
specified in the mock object, but not really implemented in the real object.
The result is that you have code that passes the tests but fails in production.
You can prevent this from happening by setting the `autospec` and `spec_set`
parameters in the `patch` decorator as in line 8 below:

{% highlight python linenos %}
# test_module2.py

from mock import patch
from module2 import B

class TestB:

    @patch('module2.A', autospec=True, spec_set=True)
    def test_initialization(self, mock_A):
        # Mock A here

        subject = B()

        # Check calls to A here
{% endhighlight %}

By using `autospec` above, we are automatically defining the Mock oject with
the same specs as the actual `module1.A` class. Likewise, by using `spec_set`
above, we are "freezing" the specs of the Mock object such that we don't
accidentally create phantom mock attributes or methods in it.

That's it for now. Live long and prosper in your tests!
