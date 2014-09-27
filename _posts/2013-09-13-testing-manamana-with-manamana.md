---
layout: post
title: Testing ManaMana with ManaMana
comments: true
categories: software development, automated testing, tdd, bdd
---
Last night at the [September LA Ruby Meetup](http://www.meetup.com/laruby/events/129338842/), I got the chance to present [ManaMana](https://github.com/ManaManaFramework/manamana), my BDD framework hobby project, and the tools I used to build it. At one point during the presentation, Michael Hartl (author of [Rails Tutorial](http://ruby.railstutorial.org/)), asked if ManaMana can test itself. It didn't at that time.

Obviously, the idea of a self-testing ManaMana gnawed on me for the rest of the night. So earlier today, I decided to give it a go. Now, I have [these files](https://gist.github.com/relaxdiego/6557728) in the project and when I run `bundle exec guard` from the command line and save the requirement or test case files above, ManaMana compiles the test and produces [the following output](https://gist.github.com/relaxdiego/6557806). So yeah, we now have a self-testing test framework with ManaMana.

[Here's the branch](https://github.com/ManaManaFramework/manamana/tree/self-test) where I have this self-testing ability. Look in the `mana` directory for the requirements and tests.

## Postscript

Like what I said in last night's presentation, the reason why I wrote this framework is pretty much the same reason people want to climb Mount Everest: because it's there. This is more a hobby for me than anything else at this point and I will still keep working on this gem when time permits. To be frank though, over the course of the past few months, I've become less convinced that this way of testing software (human language driven with layers of conversion/translation underneath) is the best way to go for most or even any situation. I'm not totally closing my mind on it, but the doubt is there. 

## Post-postscript

I'm adding this to reinforce my thought above which is that unit- and integration-testing in this way is inefficient. Unit testing tools such as RSpec and MiniTest is the better way to go. However, I continue to believe that this free-form way of capturing and validating user requirements is the way to go and is less constraining than the Given-When-Then format.