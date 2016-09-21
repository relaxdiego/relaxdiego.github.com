---
layout: post
title: Writing Ansible Modules Complete With Tests
comments: true
categories: software development, automated testing, code coverage, agile, tdd, bdd
---
Article Version: 1.1.5

While writing an ansible module, I noticed that there wasn't any resource that completely
described how to get started on my local dev environment. This article documents
the steps that I took to get up and running. Hopefully it will be a helpful
resource for you too.

I should mention though that the following resources helped me get started quickly
in certain aspects. So a big thanks to the authors! This article builds on these
foundations.

- [Unit Testing Ansible Modules](http://linuxsimba.com/unit_testing_ansible_modules_part_1)
- [Module Development Page](http://docs.ansible.com/ansible/developing_modules.html#testing-modules)
- Matt Clay on the [ansible-devel mailing list](https://groups.google.com/forum/#!forum/ansible-devel)
  and IRC for guiding me on the nuances of submitting tests with the modules.

## Sidebar: If You See Any Errors in This Doc

Please don't hesitate to let me know via the comments below or, if pull requests are
your kind of thing, the source for this website is on
[GitHub](https://github.com/relaxdiego/relaxdiego.github.com).


## Prerequisites

- Git branching basics. [Learn Git Branching](http://learngitbranching.js.org)
  is a great resource!

- Python >= 2.7.8 && < 3.0.0. NOTE: You might be able to get the code 
  samples in this article to work on Python 3.x but I haven't tried it yet.

- Pip

- The following Python libraries:
    - paramiko
    - PyYAML
    - Jinja2
    - httplib2
    - six
    - nose

- Basic testing knowledge including mocking. If you're not too familiar with
  mocking, you can still follow along but I would encourage your to read up
  on it after you're done here as it will help make your unit tests more robust.


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
git commands, I'll be using these below so feel free to add these to
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
notice that the output is different from when you run the command one
level up. If you're not familiar with git submodules, it's really just
a separate git repo that's being referenced by a parent repo. when we
ran our `git clone` command earlier with the `--recursive` option, git
also automatically cloned this repo and put it in lib/ansible/modules/extras.

If you view this repo's remotes, you will see:

    $ git remote -v
    origin        https://github.com/ansible/ansible-modules-extras (fetch)
    origin        https://github.com/ansible/ansible-modules-extras (push)


We want the naming of this repo's remotes to be consistent with that of
your **ansible repo**. So let's rename origin to upstream:

    $ git remote rename origin upstream

Then, if you haven't already done so, create a fork in Github of the
[ansible-modules-extras](https://github.com/ansible/ansible-modules-extras)
repo. Make sure to put the fork in the same account where you placed your 
fork of the Ansible repo.

Now, add that fork as a remote to your local repo and name it 'origin':

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


## SIDEBAR: Here Be (Testing) Dragons!

I expect that you already know how to write good tests and mocks because I
don't have time to teach you that. If you don't, you might still be able to 
follow along and make out a few things but testing know-how will go a long 
way in these parts.

If you're confident with your mad testing skillz but your mocking-fu is a bit
rusty, I will have to ask you to read
[Mocking Objects in Python](http://www.relaxdiego.com/2014/04/mocking-objects-in-python.html).
It's a quick 5~6-minute read.



## Let's Write the Test First

Next, while still in your **ansible repo**, create a unit test directory 
for your module:

    $ mkdir -p test/units/modules/extras/cloud/somebodyscomputer

IMPORTANT: Make sure you run the above command from the root of your 
**ansible repo** and not from the root of your **extras repo**.


## Did you notice something?

Astute readers might have noticed that while we will be writing our module
in the **extras repo**, its respective tests will be written in the **ansible
repo**. That means that, later on, you'll be submitting a pull request to
the upstream extras repo (which will contain your module code) and another PR
to the upstream ansible repo (which will contain your unit tests). Unfortunately,
that will have to be the way it's done for now until both repos are combined. For more
information, see [https://github.com/ansible/proposals/blob/master/modules-management.md](https://github.com/ansible/proposals/blob/master/modules-management.md).
I'll walk you through the process of submission later in this article.


## On With the Tests

We want our module to instantiate AnsibleModule and accept two arguments,
namely url and dest. So let's write our test to validate that.

First, since we're going to be using nose as our test framework, we have to
ensure that every subdirectory in the following path has an `__init__.py`,
otherwise nose will not load our tests. Go ahead and make sure there's
that file in every directory in this path in your **ansible repo**:

    touch test/__init__.py
    touch test/units/__init__.py
    touch test/units/modules/__init__.py
    touch test/units/modules/extras/__init__.py
    touch test/units/modules/extras/cloud/__init__.py
    touch test/units/modules/extras/cloud/somebodyscomputer/__init__.py


Next create `test/units/modules/extras/cloud/somebodyscomputer/test_firstmod.py`
with the following contents:


{%highlight python linenos%}
import unittest
import mock

from ansible.modules.extras.cloud.somebodyscomputer import firstmod


class TestFirstMod(unittest.TestCase):

    @mock.patch("ansible.modules.extras.cloud.somebodyscomputer.firstmod"
                ".AnsibleModule", autospec=True)
    def test__main__success(self, ansible_mod_cls):
        firstmod.main()

        expected_arguments_spec = dict(
            url=dict(required=True),
            dest=dict(required=False, default="/tmp/firstmod")
        )
        self.assertEqual(mock.call(argument_spec=expected_arguments_spec),
                         ansible_mod_cls.call_args)
{%endhighlight%}

- **Line 9 to 10** - We're mocking AnsibleModule making sure autospec is True so 
  that we don't create a false positive when we accidentally fat-finger 
  arguments and methods. We also don't do anything else with the mock until 
  we do our assertions because this test is only about checking if the module 
  provided the correct values to argument_spec.
- **Line 18** - This is where we assert the call to our mock class to check
  if it was called properly.

Let's execute this test. From the **extras repo**, run:

    $ nosetests --doctest-tests -v test/unit/cloud/somebodyscomputer/test_firstmod.py


This should get you an error because we haven't written our module yet:

    Failure: ImportError (cannot import name firstmod) ... ERROR

    ======================================================================
    ERROR: Failure: ImportError (cannot import name firstmod)
    ----------------------------------------------------------------------
    Traceback (most recent call last):
      File "/usr/local/var/pyenv/versions/2.7.10/lib/python2.7/site-packages/nose/loader.py", line 418, in loadTestsFromName
        addr.filename, addr.module)
      File "/usr/local/var/pyenv/versions/2.7.10/lib/python2.7/site-packages/nose/importer.py", line 47, in importFromPath
        return self.importFromDir(dir_path, fqname)
      File "/usr/local/var/pyenv/versions/2.7.10/lib/python2.7/site-packages/nose/importer.py", line 94, in importFromDir
        mod = load_module(part_fqname, fh, filename, desc)
      File "/src/ansible/lib/ansible/modules/core/test/unit/cloud/somebodyscomputer/test_firstmod.py",
     line 4, in <module>
        from cloud.somebodyscomputer import firstmod
    ImportError: cannot import name firstmod

    ----------------------------------------------------------------------
    Ran 1 test in 0.001s

    FAILED (errors=1)


## SIDEBAR: That's a Lot of Typing Just to Run One Test!

Well, if you set up your editor properly, you can run it with as few as
two keystrokes! Don't know how to do it, check out
[what I did](http://www.relaxdiego.com/2015/11/my-dev-setup-part-3.html).


## Let's Write Our First Code to Pass the Test

Create `<extras repo>/cloud/somebodyscomputer/firstmod.py` with the following contents:


{%highlight python linenos%}
#!/usr/bin/python
from ansible.module_utils.basic import AnsibleModule


def main():
    AnsibleModule(
        argument_spec=dict(
            url=dict(required=True),
            dest=dict(required=False, default="/tmp/firstmod")
        )
    )

if __name__ == '__main__':
    main()
{%endhighlight%}

Run the test again to see it pass:

    ansible.modules.core.test.unit.cloud.somebodyscomputer.test_firstmod.TestFirstMod.test__main__success ... ok

    ----------------------------------------------------------------------
    Ran 1 test in 0.024s

    OK


## Now Let's Actually Write Useful Code!

Our module doesn't do much other than accept arguments, initialize a class,
then exit. Let's make it more useful. First, we update the test with additional
mocks and expectations. So let's replace the contents of our test with this:


{%highlight python linenos%}
import unittest
import mock

from ansible.modules.extras.cloud.somebodyscomputer import firstmod


class TestFirstMod(unittest.TestCase):

    @mock.patch("ansible.modules.extras.cloud.somebodyscomputer.firstmod"
                ".write_data", autospec=True)
    @mock.patch("ansible.modules.extras.cloud.somebodyscomputer.firstmod"
                ".fetch_data", autospec=True)
    @mock.patch("ansible.modules.extras.cloud.somebodyscomputer.firstmod"
                ".AnsibleModule", autospec=True)
    def test__main__success(self, ansible_mod_cls, fetch_data, write_data):
        # Prepare mocks
        mod_obj = ansible_mod_cls.return_value
        args = {
            "url": "https://www.google.com",
            "dest": "/tmp/somelocation.txt"
        }
        mod_obj.params = args

        # Exercise code
        firstmod.main()

        # Assert call to AnsibleModule
        expected_arguments_spec = dict(
            url=dict(required=True),
            dest=dict(required=False, default="/tmp/firstmod")
        )
        self.assertEqual(mock.call(argument_spec=expected_arguments_spec),
                         ansible_mod_cls.call_args)

        # Assert call to fetch_data
        self.assertEqual(mock.call(mod_obj, args["url"]), fetch_data.call_args)

        # Assert call to write_data
        self.assertEqual(mock.call(fetch_data.return_value, args["dest"]),
                         write_data.call_args)

        # Assert call to mod_obj.exit_json
        expected_args = dict(
            msg="Retrieved the resource successfully",
            changed=True
        )
        self.assertEqual(mock.call(**expected_args), mod_obj.exit_json.call_args)
{%endhighlight%}

- **Line 9 and 12** - We're mocking two internal methods that we want
  our main method to call. I know some purists will be shocked at this saying
  that internal methods should not be mocked. My response is that sometimes
  you have to do this to avoid making your tests too complicated.
- **Line 18 to 22** - We're mocking the params attribute of the AnsibleModule
  instance since it's needed by our test subject.
- **Line 28 to 47** - We then check wether the method calls that we care about
  were called correctly by our test subject.
  
Running the above test should result in a failure, naturally. So let's write the
code to pass it. Your `firstmodule.py` should now look like this:


{%highlight python linenos%}
#!/usr/bin/python
from ansible.module_utils.basic import AnsibleModule


def main():
    mod = AnsibleModule(
        argument_spec=dict(
            url=dict(required=True),
            dest=dict(required=False, default="/tmp/firstmod")
        )
    )

    data = fetch_data(mod, mod.params["url"])
    write_data(data, mod.params["dest"])

    mod.exit_json(msg="Retrieved the resource successfully", changed=True)


def fetch_data(mod, url):
    raise NotImplementedError


def write_data(data, dest):
    raise NotImplementedError

if __name__ == '__main__':
    main()
{%endhighlight%}

You'll notice that our `fetch_data` and `write_data` methods only raise an exception.
That's intended because we don't care about it yet at this point. Remember that we
mocked these methods in our test. Run the tests and see it pass.


## SIDEBAR: But If They're Mocked, Why Write The Methods At All?

That's because, if you look back at the test, I patched them with the `autospec` 
argument set to `True`. When we do that, the test will throw an error saying 
that the method signatures could not be found. This is a great way to protect 
ourselves from creating a mock of a class or method signature that doesn't 
actually exist. If this protection was not in place, we'll create false positives 
everywhere in our test, rendering it useless.


## Let's Implement fetch_data()

We're going to make use of `StringIO` here to simulate the return value of
an ansible `mod_util` package which we'll have `fetch_data()` use. At the top of
your `test_firstmod.py`, add this line:

{%highlight python linenos%}
from StringIO import StringIO
{%endhighlight%}

Then let's add this to the bottom of the same file:

{%highlight python linenos%}
     # fetch_data test
     @mock.patch("ansible.modules.extras.cloud.somebodyscomputer.firstmod"
                 ".fetch_url", autospec=True)
     @mock.patch("ansible.modules.extras.cloud.somebodyscomputer.firstmod"
                 ".AnsibleModule", autospec=True)
     def test__fetch_data__success(self, ansible_mod_cls, fetch_url):
         # Mock objects
         mod_obj = ansible_mod_cls.return_value
         url = "https://www.google.com"

         html = "<html><head></head><body></body></html>"
         data = StringIO(html)
         info = {'status': 200}
         fetch_url.return_value = (data, info)

         # Exercise the code
         returned_value = firstmod.fetch_data(mod_obj, url)

         # Assert the results
         expected_args = dict(module=mod_obj, url=url)
         self.assertEqual(mock.call(**expected_args), fetch_url.call_args)

         self.assertEqual(html, returned_value)
{%endhighlight%}

- **Line 2 to 3** - We patch ansible's fetch_url utility method making sure to set
  `autospec` to `True`
- **Lines 8 and 9** - We prepare the arguments to pass to our test subject
- **Lines 11 to 14** - We mock out `fetch_url`.
- **Lines 21 to 24** - We then check wether our test subject made the correct
  call to `fetch_url` and then also check that it returned the correct value.
  
Run the test and see it fail. Let's now write the code that makes it pass.
First, add this near the top of your `firstmod.py` right after the first
import line:

    from ansible.module_utils.urls import fetch_url

Then, modify your `fetch_data` method to look like this:

{%highlight python linenos%}
def fetch_data(mod, url):
    data, _ = fetch_url(module=mod, url=url)
    return data.read()
{%endhighlight%}

Run the test again. BOOM!


## Let's Implement write_data()

Add the following test to the bottom of `test_firstmod.py`:

{%highlight python linenos%}
    # write_data test
    def test__write_data__success(self):
        html = "<html><head></head><body></body></html>"
        dest = "/tmp/somelocation.txt"

        o_open = "ansible.modules.extras.cloud.somebodyscomputer.firstmod.open"
        m_open = mock.mock_open()
        with mock.patch(o_open, m_open, create=True):
            firstmod.write_data(html, dest)

        self.assertEqual(mock.call(dest, "w"), m_open.mock_calls[0])
        self.assertEqual(mock.call().write(html), m_open.mock_calls[2])
{%endhighlight%}

- **Lines 6 to 8** - We expect the test subject to use the builtin
  `open` method when it writes the file. This is the de facto way of mocking it.
- **Line 11** - We check that the test subject opened the destination
  file for writing.
- **Line 12** - We check that the test subject actually wrote to the
  destination file.

You know the drill. Run to fail. Now write the code to pass it:

{%highlight python linenos%}
def write_data(data, dest):
    with open(dest, 'w') as dest:
        dest.write(data)
{%endhighlight%}

Run the test again. BOOM!

## Almost There!

Let's run the linter against our module:

    $ ansible-validate-modules <path to module dir>

That should list a few errors about documentation, examples,
and the GPLv3 license header. Let's fix that by adding the following
between the import declarations and the `main()` method:

{%highlight python linenos%}
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
# Just download it
- firstmod:
    url: https://www.google.com

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

    $ git add .
    $ git commit -m "First module"
    $ git push origin

Head on over to your Github fork of the extras repo and create a pull request
out of the commit you just pushed. Once the PR has been created, copy the PR's
URL to your clipboard since you will need to reference it from the next PR we
will create next.

Run the following from the **ansible repo**:

    $ git add .
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
      --cover-html-dir=/tmp/coverage -w test/unit/cloud/somebodyscomputer

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

## What, You're Still Here??!

Yup, that's the end of it for now. Post in the comments or
[file a bug](https://github.com/relaxdiego/relaxdiego.github.com/issues/new)
if you find any errors or have any questions.
