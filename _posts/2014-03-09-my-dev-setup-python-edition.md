---
layout: post
title: My Development Setup (Python Edition)
comments: true
categories: software development, continuous testing, automated testing, code coverage, agile, tdd, bdd, python
---

Now that my work includes coding in Python, the first thing that I paid
attention to was all the Python tools that allowed me to replicate [my dev
setup in Ruby](/2013/06/my-dev-setup.html). Here's what I have so far.

## TDD

Testing to me these days is a lot like seatbelts while riding a car. I do not
feel safe without them. So mastering a testing framework is always top priority for me when diving into a new language. I tried [nose](https://nose.readthedocs.org/en/latest/) but it appears to have lost favor
from [one of the open-source communities I'm in](http://openstacksummitfall2012.sched.org/event/524523c3c35a299ce12236cc4ccdc8e6#.Ux0NnuddXQ8).

Below is a screenshot of a skeleton project I created that is supported by
[unittest](http://docs.python.org/2/library/unittest.html), [testtools](https://pypi.python.org/pypi/testtools), and [testrepository](http://testrepository.readthedocs.org/en/latest/MANUAL.html#listing-tests) working in concert.

![Test Framework Combo](/assets/images/skeleton_py_01.png)

Some things to note in the above code are the following:

* As per [OpenStack coding guidelines](http://docs.openstack.org/developer/hacking/), imports should be segmented into three parts when necessary: imports from stdlib, imports from third-party libs, and finally imports within the project.
* PEP8 spacing is followed. Later in this article I will show how PEP8 compliance is automatically checked.

Some examples for using this test framework combo are as follows.

![Working With the Test Framework](/assets/images/skeleton_py_02.png)

There are a few things going on in that screenshot so let's break it down to the meaty parts:

* The prompt (or rastaprompt!) is made up of three parts: a) the current directory, b) the current git branch via [git-prompt.sh](https://github.com/git/git/blob/master/contrib/completion/git-prompt.sh), and c) the current virtualenv via [virtualenvwrapper postactivate hook](http://virtualenvwrapper.readthedocs.org/en/latest/scripts.html#postactivate).
* The first command lists the tests in my tests directory
* The second command executes all discovered tests. There's likely a way to customize this command's output but I haven't discovered it yet.
* The third command runs a specific test. Note that the namespace path to the test is exactly how it is listed in the output to the first command.

## Continuous Testing

Continuous testing is a very important part of a development workflow and is, I would say, at the same level of importance as continuous integration. So I was very pleased to find that this is also easily implemented in Python as it is in Ruby. For Python, I came across [sniffer](https://pypi.python.org/pypi/sniffer) which supported nose out of the box but was configurable enough to run testr and friends too. So now, when I edit a file in my project, sniffer detects the change and runs testr automatically:

![In Good standing](/assets/images/skeleton_py_03.png)

Here's another screenshot where I deliberately fail the test:

![Back to work](/assets/images/skeleton_py_04.png)

Here's another screenshot showing how sniffer also automatically ran [flake8](https://pypi.python.org/pypi/flake8) after my tests and detected a trailing whitespace:

![Trailing whitespace](/assets/images/skeleton_py_05.png)

Right now, I've only configured sniffer to indiscriminately run all test instead of selectively running tests depending on which file changed. This is easily configured though by overriding a sniffer class and adding some logic there.

## Monitoring Code Coverage

I found [coverage](https://pypi.python.org/pypi/coverage) which does the job just as well as Ruby's SimpleCov:

![Code coverage](/assets/images/skeleton_py_06.png)

Here's the HTML report showing which lines ran and which were skipped

![Code coverage repot](/assets/images/skeleton_py_07.png)

As with Ruby's SimpleCov, green lines were executed while red lines were not.

## Summary

I've gotten so used to continuous testing on my local environment that coding without it feels like driving without seatbelts. It's really good to know that Python is just as feature rich in this regard as Ruby.