---
layout: post
title: Writing Ansible Modules Complete With Tests
comments: true
categories: software development, automated testing, code coverage, agile, tdd, bdd
---
Article Version: 2.0.0

While writing an ansible module, I noticed that there wasn't any resource that completely
described how to get started on my local dev environment. This article documents
the steps that I took to get up and running. Hopefully it will be a helpful
resource for you too.

I should mention though that the following resources helped me get started quickly
in certain aspects. So a big thanks to the authors! This article builds on these
foundations.

- [Unit Testing Ansible Modules](http://linuxsimba.com/unit_testing_ansible_modules_part_1)
- [Module Development Page](http://docs.ansible.com/ansible/developing_modules.html#testing-modules)
- [Matt Clay](https://github.com/mattclay), [John Barker](https://github.com/gundalow),
  [Toshio Kuratomi](https://github.com/abadger), [Brian Coca](https://github.com/bcoca), 
  [Tim Rupp](https://github.com/caphrim007), [Allen Sanabria](https://github.com/linuxdynasty), 
  and the rest of the folks at #ansible-devel for giving me valuable feedback!

## Sidebar: If You See Any Errors in This Doc

Please don't hesitate to let me know via the comments below or, if pull requests are
your kind of thing, the source for this website is on
[GitHub](https://github.com/relaxdiego/relaxdiego.github.com).


## Prerequisites

- Git branching basics. [Learn Git Branching](http://learngitbranching.js.org)
  is a great resource!

- Python >= 2.7.8 && < 3.0.0. NOTE: Ansible works with Python 3.0+ and you 
  might be able to get the code samples in this article to work on it but I 
  haven't tried it yet.

- Pip

- The following Python libraries:
    - paramiko
    - PyYAML
    - Jinja2
    - httplib2
    - six
    - nose

- Basic testing knowledge including mocking. If you're not too familiar with
  mocking, you can still follow along but I encourage you to read up on it 
  after you're done here as it will help make your unit tests more robust.


## Prep Your Ansible Repo

If you haven't already done so, fork the [Ansible](https://github.com/ansible/ansible)
repo to a GitHub account or organization you have access to. Afterwards, clone your
fork recursively (includes any git submodules):

    $ git clone git@github.com:<your-github-account>/ansible.git --recursive

Then, add the upstream Ansible repo as 'upstream'

    $ cd ansible
    $ git remote add upstream https://github.com/ansible/ansible

After this, you now should have two remotes with 'origin' pointing to your Github
fork of the repo, and 'upstream' pointing to the upstream repo. You won't be
able to push upstream but you can fetch from it and then create pull requests
which is how it should be.

    $ git remote -v
    origin  git@github.com:<your-github-account>/ansible.git (fetch)
    origin  git@github.com:<your-github-account>/ansible.git (push)
    upstream        https://github.com/ansible/ansible (fetch)
    upstream        https://github.com/ansible/ansible (push)

I'm going to refer to your local clone as your  **ansible repo** from now on.


## Sidebar: Add a Few Git Aliases to Your Toolkit!

You don't have to do this but if you want to follow along with my
git commands, I'll be using these below so feel free to add them to
your `~/.gitconfig` under the aliases section:

    [alias]
    fa = fetch --all
    t = log --graph --pretty=oneline --abbrev-commit --decorate --color
    ta = log --graph --pretty=oneline --abbrev-commit --decorate --color --all

With these, you'll gain the following `git` commands:

- `git fa` - Fetch (but don't merge) the latest from all remotes
- `git t` - See the history of the current branch laid out in a tree
- `git ta` - See the history of the entire repo laid out in a tree


## Prep Your Extras Modules Repo

Go to the extras modules subdir

    $ cd lib/ansible/modules/extras

You are now in a git submodule. If you run `git ta` here, you will
notice that the output is different from when you run the same command one
level up. If you're not familiar with git submodules, it's really just
a separate git repo that's being referenced by a parent repo. when we
ran our `git clone` command earlier with the `--recursive` option, git
also automatically cloned this repo and put it in `lib/ansible/modules/extras`.

If you view this repo's remotes, you will see:

    $ git remote -v
    origin        https://github.com/ansible/ansible-modules-extras (fetch)
    origin        https://github.com/ansible/ansible-modules-extras (push)


To avoid confusing yourself as you work on your first module, you'll want the naming 
of this repo's remotes to be consistent with that of your **ansible repo**. 
So let's rename origin to upstream:

    $ git remote rename origin upstream

Then, if you haven't already done so, create a fork in Github of the
[ansible-modules-extras](https://github.com/ansible/ansible-modules-extras)
repo. Make sure to put the fork in the same account where you placed your 
fork of the Ansible repo.

After you've created the fork, add it as a remote to your local repo and 
name it 'origin':

    $ git remote add origin git@github.com:<your-github-account>/ansible-modules-extras.git

Your remotes list should now be:

    $ git remote -v
    origin  git@github.com:<your-github-account>/ansible-modules-extras.git (fetch)
    origin  git@github.com:<your-github-account>/ansible-modules-extras.git (push)
    upstream        https://github.com/ansible/ansible-modules-extras (fetch)
    upstream        https://github.com/ansible/ansible-modules-extras (push)

I'm going to refer to this local clone as your **extras repo** from now on.

NOTE: If you plan on contributing to the core modules repo too, just repeat 
the same steps above but replace extras with core.


## Prepare Your Environment For Local Development

While at the root dir of your **ansible repo**, run the following:

    $ source hacking/env-setup

This will prepare your current terminal session and prepend the current
ansible repo to your $PATH. Running `ansible --version` should get you
something similar to this:

    ansible 2.2.0 (devel e81f14ab48) last updated 2016/06/09 09:45:16 (GMT -700)
      lib/ansible/modules/core: (detached HEAD b37429f6ed) last updated 2016/06/10 09:08:18 (GMT -700)
      lib/ansible/modules/extras: (detached HEAD 93b59ba852) last updated 2016/06/09 09:45:29 (GMT -700)
      config file = 
      configured module search path = Default w/o overrides

Provided you didn't have any shims messing up your path, running
`which ansible` should now show the `<path to your local ansible repo>/bin/ansible`.
If not, you probably have some crazy shim-y stuff going on. Fix that before proceeding.

If you want to make this permanent, add the following to your `~/.bash_profile` or
`~/.bashrc`:

    source <path to ansible repo>/hacking/env-setup

## SIDEBAR: Keep Your Sanity. Use vim + tmux!

...well, if you're already familiar with these tools, that is.

To avoid having to cd up and down as I work on my modules, I use test.vim
with vim and split my tmux windows into the following panes:

[![](/assets/images/ansible-vim-tmux.png)](/assets/images/ansible-vim-tmux.png)
<center>Click to expand</center>

1. The top pane is dedicated to Vim
2. Lower left pane is my local **ansible repo**
3. Lower middle pane is my local **extras repo**
4. Lower right pane is for running my tests which I can quickly initiate
   from Vim thanks to test.vim by pressing `,s` (run nearest test),
   `,t` (run all tests in current file), and `,a` (run all tests)

I have my dotfiles project [here](https://github.com/relaxdiego/dotfiles). Yes
I still need to convert it to an Ansible playbook!


## Install The Ansible Module Validator (Linter)

It's like Flake8 for Ansible. Install it with:

    $ pip install git+https://github.com/sivel/ansible-testing.git#egg=ansible_testing

From your **ansible repo**, run it with:

    $ ansible-validate-modules lib/ansible/modules/core/cloud/amazon

It shouldn't output anything since the amazon core modules are compliant.
We will see it in a fouler mood later when we write a sample module.


## Create Your First Module

Let's write a module for a fictitious cloud provider named Somebody's Computer.
First, in the **extras repo**, let's create our module's subdir:

    $ mkdir cloud/somebodyscomputer
    $ touch cloud/somebodyscomputer/__init__.py

From now on, I'll refer to this as your **module dir**.


## Let's kick the tires for a bit...

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
strategy. It's best used alongside unit tests and `ansible-validate-modules`
which we'll use next.

Run:

    $ ansible-validate-modules <path to your first module dir>

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
I'll walk you through the process of submission later in this article.


## On With the Tests

Let's make `save_data()` actually do some work. We'll design it to fetch
the resource and then write it to disk. First, since we're going to be using 
nose as our test framework, we have to ensure that every subdirectory in the 
following path has an `__init__.py`, otherwise nose will not load our tests. 
Go ahead and make sure there's that file in every directory in this path in 
your **ansible repo**:

    touch test/__init__.py
    touch test/units/__init__.py
    touch test/units/modules/__init__.py
    touch test/units/modules/extras/__init__.py
    touch test/units/modules/extras/cloud/__init__.py
    touch test/units/modules/extras/cloud/somebodyscomputer/__init__.py


Next create `test/units/modules/extras/cloud/somebodyscomputer/test_firstmod.py`
as follows:

{%highlight python linenos%}
# Make coding more python3-ish
from __future__ import (absolute_import, division)
__metaclass__ = type

from ansible.compat.tests import unittest
from ansible.compat.tests.mock import call, create_autospec, patch
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


## Let's Implement fetch()

First, let's write the test:

{%highlight python linenos%}
    @patch('ansible.modules.extras.cloud.somebodyscomputer.firstmod.open_url')
    def test__fetch__happy_path(self, open_url):
        # Setup
        url = "https://www.google.com"

        # mock the return value of open_url
        stream = open_url.return_value
        stream.read.return_value = "<html><head></head><body>Hello</body></html>"
        stream.getcode.return_value = 200
        open_url.return_value = stream

        # Exercise
        data = firstmod.fetch(url)

        # Verify
        self.assertEqual(stream.read.return_value, data)

        self.assertEqual(1, open_url.call_count)

        expected = call(url)
        self.assertEqual(expected, open_url.call_args)
{%endhighlight%}

- **Line 1** - We patch an Ansible function which we expect `fetch()` to call
- **Line 4** - The url that we will pass on to `fetch()`. We're assigning it to
  a variable here because we want to verify if it gets passed on to `open_url()`
- **Lines 7 to 10** - We mock the IO object that `open_url` returns to `fetch()`
- **Lines 16 to 21** - We verify if `fetch()` returned the correct data and that
  it called the underlying `open_url()` correctly.
  
Run the test and see it fail. Let's now write the code that makes it pass.
First, add this near the top of your `firstmod.py` right after the first
import line:

{%highlight python linenos%}
from ansible.module_utils.urls import open_url
{%endhighlight%}

Then, modify your `fetch()` method to look like this:

{%highlight python linenos%}
def fetch(url):
    try:
        stream = open_url(url)
        return stream.read()
    except URLError:
        raise FetchError("Data could not be fetched")
{%endhighlight%}

Notice that we're catching a `URLError` here. Import that class as follows:

{%highlight python linenos%}
from urllib2 import URLError
{%endhighlight%}

Notice also that we're raising a custom error class here called `FetchError`. This is
so that we don't have to write an `except Exception` catchall in `save_data()`
which is poor error handling. So let's add the following class to the file. I typically 
write this near the top, just after the imports.

{%highlight python linenos%}
class FetchError(Exception):
    pass
{%endhighlight%}

Run the test again and see it pass.


## Let's Implement write()

Add the following test to `test_firstmod.py`:

{%highlight python linenos%}
    def test__write__happy_path(self):
        # Setup
        data = "Somedata here"
        dest = "/path/to/file.txt"

        # Exercise
        o_open = "ansible.modules.extras.cloud.somebodyscomputer.firstmod.open"
        m_open = mock_open()
        with patch(o_open, m_open, create=True):
            firstmod.write(data, dest)

        # Verify
        expected = call(dest, "w")
        self.assertEqual(expected, m_open.mock_calls[0])

        expected = call().write(data)
        self.assertEqual(expected, m_open.mock_calls[2])
{%endhighlight%}

- **Lines 7 to 9** - We expect the test subject to use the builtin
  `open` method when it writes the file. This is the de facto way of mocking it.
- **Line 13 to 14** - We check that the test subject opened the destination
  file for writing.
- **Line 16 to 17** - We check that the test subject actually wrote to the
  destination file.

You know the drill. Run to fail. Now write the code to pass it:

{%highlight python linenos%}
def write(data, dest):
    try:
        with open(dest, "w") as dest:
            dest.write(data)
    except IOError:
        raise WriteError("Data could not be written")
{%endhighlight%}

Like `fetch()`, this method also throws a custom exception. Add this to your
code:

{%highlight python linenos%}
class WriteError(Exception):
    pass
{%endhighlight%}

Run the test again to see it pass.

## Almost There!

Let's run the linter against our module:

    $ ansible-validate-modules <path to module dir>

That should list a few errors about documentation, examples,
and the GPLv3 license header. Let's fix that by modifying the top part
to look like this:

{%highlight python linenos%}
#!/usr/bin/python
# This file is part of Ansible
#
# Ansible is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Ansible is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Ansible.  If not, see <http://www.gnu.org/licenses/>.
# Make coding more python3-ish
from __future__ import (absolute_import, division)
__metaclass__ = type

from urllib2 import URLError

from ansible.module_utils.basic import AnsibleModule
from ansible.module_utils.urls import open_url


DOCUMENTATION = '''
---
module: firsmod
short_description: Downloads stuff from the interwebs
description:
    - Downloads stuff
    - Saves said stuff
version_added: "2.2"
options:
  url:
    description:
      - The location of the stuff to download
    required: false
    default: null
  dest:
    description:
      - Where to save the stuff
    required: false
    default: /tmp/firstmod
author:
    - "Your Name Here (@yourgithubusernamehere)"
'''

RETURN = '''
msg:
    description: Just returns a friendly message
    returned: always
    type: string
    sample: Hi there!
'''

EXAMPLES = '''
# Download then save to your home dir
- firstmod:
    url: https://www.relaxdiego.com
    dest: ~/relaxdiego.com.txt
'''
{%endhighlight%}


For an explanation of these strings, see Ansible's [Developing Modules Page](https://github.com/ansible/ansible/blob/devel/docsite/rst/developing_modules.rst#example).

Run the linter again. BOOM!


## Test The Module Manually With Arguments This Time

We can write a playbook that uses our module now if we want to
but I'll leave you to do that on your own time. For now, let's
run it using the `test-module` script that comes with the
**ansible repo**. Run the following:

    $ <path to ansible repo>/hacking/test-module -m <path to first module dir>/firstmod.py -a "url=https://www.google.com dest=/tmp/ansibletest.txt"

Next, run the following to see what it downloaded:

    $ cat /tmp/ansibletest.txt


## Run the Sanity Tests

It's a good idea to run the sanity tests every now and then so that you'll
know ahead of time if you've introduced some non-compliant code into the
source. From your **ansible repo** run:

    $ INSTALL_DEPS=1 TOXENV=py27 test/utils/shippable/sanity.sh

If the test fails, you may have introduced some erroneous code. Check the
error messages and fix as needed. If you're sure it's not your fault, check
if you're working on top of an old upstream commit. If that's that case, rebase
your changes to the latest from upstream and try again.


## Time To Push to Origin!

Remember that we're working on two git repos here. First is the **ansible repo**
and second is the **extras repo**. Let's work on latter the former first.

Run the following from the **extras repo**:

    $ git add cloud
    $ git commit -m "First module"
    $ git push origin

Head on over to your Github fork of the extras repo and create a pull request
out of the commit you just pushed. Once the PR has been created, copy the PR's
URL to your clipboard since you will need to reference it from the next PR we
will create next.

Run the following from the **ansible repo**:

    $ git add test
    $ git commit -m "Tests for first module"
    $ git push origin

Now head on over to your Github fork of the ansible repo and create a pull
request out of the commit you just pushed. In the PR's description, make sure
to paste the previous PR's URL so that the ansible team knows which modules
the tests are for. Once this PR is made, copy its URL as well.

Head back to the first PR you made and modify the description by pasting the
second PR's URL. This is so that the ansible team will know the tests for this
PR. This may seem cumbersome and it is but it's only temporary and will become
a single PR setup once the two repos have been combined.


## SIDEBAR: Speaking of submitting code upstream...

Always make sure that your topic branch is based off of the HEAD
of the parent branch. In our case above, we created `test_branch` off
of `upstream/devel`. While working on `test_branch`, new commits are
merged to `upstream/devel`. It is, therefore, a good idea to do this
regularly:

    $ git add .
    $ git commit
    $ git fa
    $ git rebase upstream/devel

Keep doing this until your topic branch is accepted and merged
upstream. That should put your topic branch ahead of `upstream/devel`
and avoid any merge conflicts down the line. If you do this regularly
and do encounter a merge conflict, it will be easier to fix now
than later.


## BONUS: Get some code coverage!

Writing unit tests is great but blindly writing tests is not enough. So let's
see how much of your module's code is covered. For this, we'll use Ned
Batchelder's awesome coverage library. To get started, let's install it:

    $ pip install coverage

Next, we'll use it with nose as follows:

    $ nosetests -v --with-coverage --cover-html \
      --cover-package='ansible.modules.extras.cloud.somebodyscomputer' \
      --cover-html-dir=/tmp/coverage -w test/units/modules/extras/cloud/somebodyscomputer/

By running this single command, you'll get two things. First is a quick
test coverage summary via the terminal. Second is an HTML format of the
same coverage report with information on which lines of your code has
been executed by tests or not. A green line means it's been executed
(and therefore tested) while red means it was not. Go ahead and open
`/tmp/coverage/index.html` in your browser and be enlightened!

[![](/assets/images/coverage-detail-python.png)](/assets/images/coverage-detail-python.png)


IMPORTANT: A fully covered module doesn't automatically mean it's bug free.
But the coverage report is a great way to find out which parts of your
code needs some testing TLC.


## One More Thing...

Make sure to go through the [official module checklist](http://docs.ansible.com/ansible/developing_modules.html#module-checklist)
at least once before you submit your pull request!


## What, You're Still Here??!

Yup, that's the end of it for now. Post in the comments or
[file a bug](https://github.com/relaxdiego/relaxdiego.github.com/issues/new)
if you find any errors or have any questions.


## Resources

- [Tests](https://github.com/evil-org/ansible/blob/firstmod/test/units/modules/extras/cloud/somebodyscomputer/test_firstmod.py)
- [Code](https://github.com/evil-org/ansible-modules-extras/blob/firstmod/cloud/somebodyscomputer/firstmod.py)
- [Boundaries talk by Gary Bernhardt](http://pyvideo.org/pycon-us-2013/boundaries.html)
- [Integrated Tests are a Scam by J.B. Rainsberger](https://vimeo.com/80533536)
- [Domain-Driven Design](http://a.co/fQExOv5)
