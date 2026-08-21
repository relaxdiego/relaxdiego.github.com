---
title: "Using GCC when Xcode 4.2 or 4.3 is installed"
date: 2012-02-22T10:35:00Z
slug: using-gcc-when-xcode-43-is-installed
categories: ["programming"]
---

I was having problems compiling gems from the terminal in my Mac last week.
After further investigation and some Googling, I found out that it was because
Xcode 4.3 now uses the LLVM-based gcc and not all native gems support it. I
then installed the [Command Line Tools for
Xcode](https://developer.apple.com/downloads/index.action) hoping that would
solve the problem. Unfortunately, it didn't. At least not completely.

After some more digging around, I came to realize that `/usr/bin/gcc`, which
is what gets used by default, is actually symlinked to
`/usr/bin/llvm-gcc-4.2`. I tried setting `CC=/usr/bin/gcc-4.2` whenever I
installed gems, but somehow that gets lost along the way. Some suggested that
I downgrade to Xcode 4.1 or even uninstall Xcode altogether. However, in my
case, I use Xcode every now and then so that was not an option.

Thankfully, I came across [a suggestion in
StackOverflow](http://stackoverflow.com/questions/1165361/setting-gcc-4-2-as-the-default-compiler-on-mac-os-x-leopard) which
said that I create symlinks to the classic gcc and make sure it's accessed
first when I'm in the terminal. Here's how I did it:

First, I created a hidden folder in my home directory:

``` bash
~ $ mkdir .bin
```

Next, I created symlinks in `~/.bin`:

``` bash
~ $ cd .bin
~/.bin $ ln -s /usr/bin/gcc-4.2 cc
~/.bin $ ln -s /usr/bin/gcc-4.2 gcc
~/.bin $ ln -s /usr/bin/c++-4.2 c++
~/.bin $ ln -s /usr/bin/g++-4.2 g++
```

Note that in order for those to work, the [Command Line Tools for
Xcode](https://developer.apple.com/downloads/index.action) should be
installed. You can do that via direct download or through Xcode's Downloads
preference pane.

Next, I edited `~/.bash_profile` and appended the following:

``` bash
export PATH=~/.bin:$PATH
```

The above ensures that my symlinks are used and not `/usr/bin/gcc`. I then
reloaded `.bash_profile`:

``` bash
~ $ source .bash_profile
```

After this, all native gems compiled successfully.
