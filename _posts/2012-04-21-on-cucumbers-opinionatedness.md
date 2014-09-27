---
layout: post
title: On Cucumber's Opinionatedness
comments: true
categories: software, cucumber
---
In [a previous post](/2012/04/using-cucumber.html), I said that Cucumber's flexibility is both a boon and a curse to teams who are just getting to know it. I said this because it's so easy to get started with the Gherkin syntax that users get a little too excited and start to tinker with it in their own way which doesn't always produce the right results. It's just like a game of Othello: very easy to learn, but hard to master. One has to understand the principles behind it to win.

A few days back, I read [a post](http://37signals.com/svn/posts/3159-testing-like-the-tsa) by Rails creator, DHH, about how Cucumber is not right for testing. While his conclusions of Cucumber's purpose are clearly misguided, it is still alarming: if someone who is smart enough to create a complex web app framework doesn't get Cucumber, then there must be something wrong with how it's being communicated.

A possible reason why people misunderstand Cucumber may have something to do with its homepage. If you look at [the example there](http://cukes.info/), you can see the following:

    Feature: Addition
      In order to avoid silly mistakes
      As a math idiot
      I want to be told the sum of two numbers

      Scenario: Add two numbers
        Given I have entered 50 into the calculator
          And I have entered 70 into the calculator
         When I press add
         Then the result should be 120 on the screen

No wonder a lot of folks are confused! The very first example usage of Cucumber that newcomers will see already suggests an improper use of the product. This example contradicts [The Cucumber Book](http://pragprog.com/book/hwcuc/the-cucumber-book) which states that scenarios should be declarative, not imperative. Furthermore, the example is coupled with the user interface ("When I press add") which is a big no no when writing feature files. Feature files are supposed to capture business (not UI) requirements as I suggested [here](/2012/04/using-cucumber.html).

Matt Wyne--one of the contributors of Cucumber--[recently implied](https://twitter.com/#!/mattwynne/status/193283112862629888) that it's OK to let users discover the proper way to use it on their own time. This is probably fine in the context of a workshop with a coach guiding the team but not in situations where the team is learning on their own, and on a deadline to build a piece of software--and this is probably more often the case. In this latter scenario, if it doesn't work out the first time, my guess is that they will blame the tool, dismiss it and move on. Letting users discover proper Cucumber use on their own time is also not very efficient in the grander scheme. We in the software development world should know this. We re-use libraries and refer to design patterns so that we can focus on our job, not study Computer Science 101. This is no different from Cucumber users: they need to build software, not recreate the discovery of proper Cucumber usage.

To be fair to the Cucumber community though, the tool started out in an environment that was already full of ambiguity to begin with. Take the term "Behavior Driven Development," for example. The quick explanation for BDD is that it's a way of app design that focuses on describing the system's behavior rather than its internals. However, "behavior" is an overloaded term. What does it mean? Someone can easily take "behavior" to mean "how the UI behaves" and, with a single stroke, totally misunderstood the purpose of Cucumber.

Cucumber's introduction to the world shares a lot of similarities with Rails' debut: many folks got excited and some started to come up with their own ideas for fitting it into their context. The difference is that, at the onset, the Rails community was very opinionated about how it should be used. While that might have slightly turned off some folks, it didn't stop the framework from growing to what it is now. Better to have a very limited, but well functioning tool than one that promises many things but doesn't exactly meet anyone's expectations.

In my mind, Cucumber is a business requirements specification framework that is great for capturing and automatically validating business requirements. This framework is composed of:

* A business requirements specification layer (the feature files). At the moment, Gherkin is used for this layer. It's possible that other DSLs may be used as alternatives in the future.
* A business requirements validation layer (the step definitions). At the moment, Ruby, Java, and other programming languages are used for this layer. It's possible that an english-like language may be created as an alternative.
* Libraries that help in writing the validation layer. Examples are Capybara, Watir, and libraries that implement the Page Object pattern.
* A reporting layer (Formatters). This includes the built in formatters as well as custom formatters.

Each of the above layers can be used on their own, and they might be used for different purposes, but in the context of Cucumber, there is an optimal way to use them. Diverge from that path and you produce bad cukes. Again, there is a similarity to Rails here with respect to the Model and Controllers layer: for programmers new to the MVC pattern, they often made the mistake of writing fat controllers. While this got the job done, it often resulted in code that's hard to maintain. When they shift to the fat model/skinny controller principle, which is the recommended way in Rails, suddenly the framework became even more enjoyable to use.

I may have an understanding of Cucumber that's different from others, including the the folks that created it and that's the point. If Cucumber means different things to different folks, then there's a risk of it spreading itself too thin and becoming irrelevant.

I think that it's time for Cucumber to be a bit more opinionated about how it should be used. It's a really great tool backed by a great community. How the rest of the world receives it and how it thrives in the next few years, however, depends on how clearly its purpose is communicated.