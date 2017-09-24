---
layout: post
title: Fully Automated Blog and Resume
comments: true
categories: automation, jekyll, foreman, blog, Procfile
---

I finally got around to fully automating my blog generation including
the resume rendering part (both HTML and PDF formats).
[These](https://github.com/relaxdiego/relaxdiego.github.com/commit/6b5b222ab3fa7cd6288111abfe99b79c13fbd665)
[are](https://github.com/relaxdiego/relaxdiego.github.com/commit/de069a6fb8e5f657257cbeea6bfd0509584b94e4)
[the](https://github.com/relaxdiego/relaxdiego.github.com/commit/0dab5cea040989f8220f16c555e60da0707c89af)
[changes](https://github.com/relaxdiego/relaxdiego.github.com/commit/1ad70fa95b72ae9bca80f299503a002189c95727)
that made that happen. 

So now my workflow just involves starting [<strike>Foreman</strike>](https://github.com/ddollar/foreman)
[Goreman](https://github.com/mattn/goreman) in one terminal session while I work
inside Vim in another session. [tmux](https://github.com/tmux/tmux/wiki), of
course, makes all of that easy peasy.

Automation rocks.

![Fully Automated Blog Workflow](/assets/images/automated-blog.png)
