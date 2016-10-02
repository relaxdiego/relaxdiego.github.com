---
layout: post
title: Writing Ansible Modules Part 1 - Preparing Your Environment
comments: true
categories: ansible, modules, configuration management, software development, automated testing, code coverage, agile, tdd, bdd
---
This is part 1 of a series of articles. For other parts, see 
[the introductory article](/2016/06/writing-ansible-modules-with-tests.html).


## Prerequisites

You'll need a few things handy before you can continue:

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
fork recursively so that it will also fetch associated git submodules:

    $ git clone git@github.com:<your-github-account>/ansible.git --recursive

Next, add the upstream Ansible repo as 'upstream'

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


## You're Ready to Start Developing!

Good job! Take a breather, then head on over to
[part 2](writing-ansible-modules-002.html) to create your very first
Ansible module. Alternatively, you can go back to the
[the introduction](/2016/06/writing-ansible-modules-with-tests.html)
if you want to jump ahead to other parts.
