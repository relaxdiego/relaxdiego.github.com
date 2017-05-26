---
layout: post
title: Writing Ansible Modules Part 3 - Complete the Module
comments: true
categories: ansible, modules, configuration management, software development, automated testing, code coverage, agile, tdd, bdd
---
This is part 3 of a series of articles. For other parts, see 
[the introductory article](/2016/06/writing-ansible-modules-with-tests.html).


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

    $ test/sanity/validate-modules/validate-modules <path to module dir>

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

ANSIBLE_METADATA = {'metadata_version': '1.0',
                    'status': ['preview'],
                    'supported_by': 'community'}

DOCUMENTATION = '''
---
module: firstmod
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

from urllib2 import URLError

from ansible.module_utils.basic import AnsibleModule
from ansible.module_utils.urls import open_url


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


## BONUS: Get some code coverage!

Writing unit tests is great but blindly writing tests is not enough. So let's
see how much of your module's code is covered. For this, we'll use Ned
Batchelder's awesome coverage library. To get started, let's install it:

    $ pip install coverage

Next, we'll use it with nose as follows:

    $ nosetests -v --with-coverage --cover-erase --cover-html \
      --cover-package='ansible.modules.extras.cloud.somebodyscomputer' \
      --cover-html-dir=/tmp/coverage -w test/units/modules/extras/cloud/somebodyscomputer/

By running this single command, you'll get two things. First is a quick
test coverage summary via the terminal. Second is an HTML format of the
same coverage report with information on which lines of your code has
been executed by your tests. A green line means it's been executed
(and therefore tested) while red means it was not. Go ahead and open
`/tmp/coverage/index.html` in your browser and be enlightened!

[![](/assets/images/coverage-detail-python.png)](/assets/images/coverage-detail-python.png)


IMPORTANT: A fully covered module doesn't automatically mean it's bug free.
But the coverage report is a great way to find out which parts of your
code needs some testing TLC.



## Holy Smokes!

I hope you're as pumped as I am for getting this far. You do realize that,
in just 3 articles, you went from zero to writing a fully tested Ansible
module. That's quite an achivement so grab a beer (or whatever is your
cup of...ummm...tea) and celebrate your awesomeness!

When you're ready, head over to [part 4](/2016/09/writing-ansible-modules-004.html)
where we'll learn how to submit our code upstream. Alternatively, you 
can go back to the [the introduction](/2016/06/writing-ansible-modules-with-tests.html)
if you want to jump ahead to other parts.
