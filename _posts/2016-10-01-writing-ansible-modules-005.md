---
layout: post
title: Writing Ansible Modules Part 5 - Helpful Resources
comments: true
categories: ansible, modules, configuration management, software development, automated testing, code coverage, agile, tdd, bdd
---
<sup>Co-Written by [Andreas Hubert](https://github.com/peshay)</sup>

This is part 5 of a series of articles. For other parts, see
[the introductory article](/2016/06/writing-ansible-modules-with-tests.html).


## I'm So Proud of You!

You did a rockin' job finishing this series! Now it's time for you to continue
the journey on your own but not necessarily alone. Here are some resources that
will help you become an effective module developer.

* **[The official module checklist](http://docs.ansible.com/ansible/developing_modules.html#module-checklist)** -
  This is a very useful set of items to review especially just before you
  submit code upstream. Keep it in your bookmarks!

* **[Running Integration Tests](https://docs.ansible.com/ansible/dev_guide/testing_integration.html)** -
  Here's very useful information on how to run integration tests locally.

* **The [Tests](https://github.com/evil-org/ansible/blob/firstmod/test/units/modules/extras/cloud/somebodyscomputer/test_firstmod.py)
  and [Code](https://github.com/evil-org/ansible-modules-extras/blob/firstmod/cloud/somebodyscomputer/firstmod.py)** -
  Here's the complete sample code that we built in this series. Use it as you wish!

- **[Boundaries Talk by Gary Bernhardt](http://pyvideo.org/pycon-us-2013/boundaries.html)** -
  One of my favorite talks. Here, Gary talks about designing software that's
  testable, maintainable, and all the "-able" good stuff that comes with properly designed apps.

- **[Integrated Tests are a Scam by J.B. Rainsberger](https://vimeo.com/80533536)** -
  While the title sounds controversial, it does open you up to a new way of thinking about
  your isolated/unit tests and how to avoid the hell that is managing integration tests.

- **[Domain-Driven Design](http://a.co/fQExOv5)** - Build your code's internal API such
  that it reflects the domain that it's modeling and avoid communication problems with
  your customer!

- **\#ansible-devel on Freenode** - There's a lot of friendly folks in there who will be
  more than happy to help you if you have any module development questions.

- **[ansible-devel mailing list](https://groups.google.com/forum/#!forum/ansible-devel)** -
  If IRC is not your thing, you can contact the same folks from this Google Group.

Well, that's it for now. Best of luck and see you on the Interwebz!
