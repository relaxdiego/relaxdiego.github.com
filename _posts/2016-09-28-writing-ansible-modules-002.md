---
layout: post
title: Writing Ansible Modules Part 2 - Write Your First Module
comments: true
categories: ansible, modules, configuration management, software development, automated testing, code coverage, agile, tdd, bdd
---
This is part 2 of a series of articles. For other parts, see 
[the introductory article](/2016/06/writing-ansible-modules-with-tests.html).

## It's Just Somebody's Computer

Let's write a module for a fictitious cloud provider named Somebody's Computer.
First, in the **extras repo**, let's create our module's subdir:

    $ mkdir cloud/somebodyscomputer
    $ touch cloud/somebodyscomputer/__init__.py

From now on, I'll refer to this as your **module dir**.


## Let's Kick The Tires for a Bit

First, let's create a topic branch from the HEAD of devel and work there. 
Working on a topic branch has its advantages in that, should new changes be 
added to upstream/devel, all you have to do is fetch those and then rebase 
your topic branch on top of it.

Let's create our topic branch:

    $ git checkout -b test_branch devel

Let's use the simple example from the [Module Development Page](http://docs.ansible.com/ansible/developing_modules.html#testing-modules)
just to get familiar with the terrain a bit. In your **module dir**,
create a file called `timetest.py` with the following content:

{%highlight python linenos%}
#!/usr/bin/python

import datetime
import json

date = str(datetime.datetime.now())
print json.dumps({
    "time" : date
})
{%endhighlight%}

You just created your first module! At this point, we can create a
playbook that uses your timetest module and then execute it with
ansible-playbook. But why when the Ansible repo provides a convenient 
script that allows you to bypass all that! So from your **ansible repo**, run: 

    $ hacking/test-module -m <path to module dir>/timetest.py

This should give you an output similar to the following:

    * including generated source, if any, saving to: ~/.ansible_module_generated
    ***********************************
    RAW OUTPUT
    {"time": "2016-06-09 11:00:01.445100"}


    ***********************************
    PARSED OUTPUT
    {
        "time": "2016-06-09 11:00:01.445100"
    }

What just happened is that the test-module script executed your
module without loading all of ansible. This is a nice way to quickly
do a sort-of-end-to-end test of your module after you've written your
unit tests. I **would not** recommend using it exclusively as your testing
strategy. It's best used alongside unit tests and `validate-modules`
which we'll use next.

Run:

    $ test/sanity/validate-modules/validate-modules <path to your first module dir>

This should get you the following errors:

    ============================================================================
    <path to first module dir>/timetest.py
    ============================================================================
    ERROR: No DOCUMENTATION provided
    ERROR: No EXAMPLES provided
    ERROR: Did not find a call to main
    ERROR: Did not find a module_utils import
    ERROR: GPLv3 license header not found

Ignore those errors for now while we're still kicking the tires.


## Let's Write A Real(-ish) Module!

Let's start with a clean slate. From your **extras repo** run:

    $ git reset --hard

Next, let's install some Python packages needed by our tests. From your
**ansible repo**, run:

    $ pip install -r test/utils/tox/requirements.txt

NOTE: If you're developing on Python 3.0+, use requirements-py3.txt instead

Next, let's write a module that fetches a resource pointed to by
a URL and then writes it to disk. So in our **extras repo**, create a file at 
`cloud/somebodyscomputer/firstmod.py` with the following content:

{% highlight python linenos %}
#!/usr/bin/python
# Make coding more python3-ish
from __future__ import (absolute_import, division)
__metaclass__ = type

from ansible.module_utils.basic import AnsibleModule


def save_data(mod):
    raise NotImplementedError


def main():
    mod = AnsibleModule(
        argument_spec=dict(
            url=dict(required=True),
            dest=dict(required=False, default="/tmp/firstmod")
        )
    )

    save_data(mod)


if __name__ == '__main__':
    main()
{% endhighlight %}

Let's discuss line by line:

- **Lines 1 to 4** sets up some things to make our code more or less behave
  well in Python 3
- **Lines 24 to 25** executes the `main` function
- **Lines 13 to 19** instantiates `AnsibleModule`, defining the arguments
  accepted by the module.
- **Line 21** calls the function that actually does the work. Passing the AnsibleModule
  instance to it.
- **Lines 9 to 10** defines our worker function which just raises an exception
  for now.

This is the generally accepted structure of a module. Specifically, the
`main()` function should just instantiate `AnsibleModule` and then pass that
to another function that will do the actual work. Now because `main()` is very
thin, unit testing it is pointless since the test, should we write it, will
only end up looking almost like `main()` and that's not very useful. What
we really want to test is `save_data()`.


## WARNING: Here Be (Testing) Dragons!

I expect that you already know how to write good tests and mocks because I
don't have time to teach you that. If you don't, you might still be able to 
follow along and make out a few things but testing know-how will go a long 
way in these parts.

If you're confident with your mad testing skillz but your mocking-fu is a bit
rusty, I will have to ask you to read
[Mocking Objects in Python](http://www.relaxdiego.com/2014/04/mocking-objects-in-python.html).
It's a quick 5~6-minute read.



## Let's Write the Test First

From your **ansible repo**, create a unit test directory for your module:

    $ mkdir -p test/units/modules/extras/cloud/somebodyscomputer

IMPORTANT: Make sure you run the above command from the root of your 
**ansible repo** and not from the root of your **extras repo**.


## Did you notice something?

Astute readers might have noticed that while we will be writing our module
in the **extras repo**, its respective tests will be written in the **ansible
repo**. That means that, later on, you'll be submitting a pull request to
the upstream extras repo (which will contain your module code) and another PR
to the upstream ansible repo (which will contain your unit tests). Unfortunately,
that will have to be the way it's done for now [until both repos are combined](https://github.com/ansible/proposals/blob/master/modules-management.md).
I'll walk you through the process of submission in a later article.


## On With the Tests

Let's make `save_data()` actually do some work. We'll design it to fetch
the resource and then write it to disk. First, since we're going to be using 
nose as our test framework, we have to ensure that every subdirectory in the 
following path has an `__init__.py`, otherwise nose will not load our tests. 
Go ahead and make sure there's that file in every directory in this path in 
your **ansible repo**:

    find test/units/modules/ -type d -exec touch {}/__init__.py  \;

Next create `test/units/modules/extras/cloud/somebodyscomputer/test_firstmod.py`
as follows:

{%highlight python linenos%}
# Make coding more python3-ish
from __future__ import (absolute_import, division)
__metaclass__ = type

from ansible.compat.tests import unittest
from ansible.compat.tests.mock import call, create_autospec, patch, mock_open
from ansible.module_utils.basic import AnsibleModule

from ansible.modules.extras.cloud.somebodyscomputer import firstmod


class TestFirstMod(unittest.TestCase):

    @patch('ansible.modules.extras.cloud.somebodyscomputer.firstmod.write')
    @patch('ansible.modules.extras.cloud.somebodyscomputer.firstmod.fetch')
    def test__save_data__happy_path(self, fetch, write):
        # Setup
        mod_cls = create_autospec(AnsibleModule)
        mod = mod_cls.return_value
        mod.params = dict(
            url="https://www.google.com",
            dest="/tmp/firstmod.txt"
        )

        # Exercise
        firstmod.save_data(mod)

        # Verify
        self.assertEqual(1, fetch.call_count)
        expected = call(mod.params["url"])
        self.assertEqual(expected, fetch.call_args)

        self.assertEqual(1, write.call_count)
        expected = call(fetch.return_value, mod.params["dest"])
        self.assertEqual(expected, write.call_args)

        self.assertEqual(1, mod.exit_json.call_count)
        expected = call(msg="Data saved", changed=True)
        self.assertEqual(expected, mod.exit_json.call_args)
{%endhighlight%}

- **Lines 5 to 9** - Import Python modules that we're going to need for our test
- **Lines 14 and 15** - Patch two new methods in our module, `write` and `fetch`
- **Lines 18 to 23** - Set up a mock of AnsibleModule that we will pass
  on to `save_data()`. We expect the function to get the arguments from the 
  AnsibleModule's `param` attribute, so we stubbed that in line 20.
- **Line 26** - Exercise the code
- **Lines 29 to 31** - Verify that it called `fetch` properly
- **Lines 33 to 35** - Verify that it called `write` properly
- **Lines 37 to 39** - Verify that it called `AnsibleModule.exit_json` properly


Let's execute this test. From the **extras repo**, run:

    $ nosetests --doctest-tests -v test/unit/cloud/somebodyscomputer/test_firstmod.py

This should get you an error because we haven't written any code that satisfies 
the test yet!


## SIDEBAR: That's a Lot of Typing Just to Run One Test!

Well, if you set up your editor properly, you can run it with as few as
two keystrokes! Don't know how to do it, check out
[what I did](http://www.relaxdiego.com/2015/11/my-dev-setup-part-3.html).


## Let's Write Code to Pass the Test

{%highlight python linenos%}
#!/usr/bin/python
# Make coding more python3-ish
from __future__ import (absolute_import, division)
__metaclass__ = type

from ansible.module_utils.basic import AnsibleModule


def fetch(url):
    raise NotImplementedError


def write(data, dest):
    raise NotImplementedError


def save_data(mod):
    data = fetch(mod.params["url"])
    write(data, mod.params["dest"])
    mod.exit_json(msg="Data saved", changed=True)


def main():
    mod = AnsibleModule(
        argument_spec=dict(
            url=dict(required=True),
            dest=dict(required=False, default="/tmp/firstmod")
        )
    )

    save_data(mod)


if __name__ == '__main__':
    main()
{%endhighlight%}

Run the test again to see it pass:

    ansible.modules.core.test.unit.cloud.somebodyscomputer.test_firstmod.TestFirstMod.test__save_data__happy_path ... ok

    ----------------------------------------------------------------------
    Ran 1 test in 0.024s

    OK


## Testing for Failures

The happy path is always the first path that I test but I don't stop there. In
this context, I also test for when `fetch()` or `write()` fail. The steps are
fairly similar to the happy path so I'll leave it to you to see how I did it
by looking at the final [test](https://github.com/evil-org/ansible/blob/firstmod/test/units/modules/extras/cloud/somebodyscomputer/test_firstmod.py) and 
[source code](https://github.com/evil-org/ansible-modules-extras/blob/firstmod/cloud/somebodyscomputer/firstmod.py).


## You Rock!

You made it this far and that deserves a pat on the back. Good job again! 
Take another breather, then head on over to [part 3](writing-ansible-modules-003.html) 
where we'll continue implementing our first module. Alternatively, you 
can go back to the [the introduction](/2016/06/writing-ansible-modules-with-tests.html)
if you want to jump ahead to other parts.
