---
layout: post
title: Writing Ansible Modules Part 4 - Submitting Code Upstream
comments: true
categories: ansible, modules, configuration management, software development, automated testing, code coverage, agile, tdd, bdd
---
This is part 4 of a series of articles. For other parts, see 
[the introductory article](/2016/06/writing-ansible-modules-with-tests.html).


## Time To Push to Origin!

Remember that we're working on two git repos here. First is the **ansible repo**
and second is the **extras repo**. Let's work on the latter first.

Run the following from the **extras repo**:

    $ git add cloud/
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


## Wazaap, Open Source Contributor!

Yup, I'm talking to you. You're totally rocking that open source thing!

Before we go our separate ways, I'll share with you some more resources that
you might find helpful as you continue your journey of awesomeness. For that,
head over to [part 5](/2016/10/writing-ansible-modules-005.html). Alternatively, 
you can go back to the [the introduction](/2016/06/writing-ansible-modules-with-tests.html)
if you want to jump to other parts.
