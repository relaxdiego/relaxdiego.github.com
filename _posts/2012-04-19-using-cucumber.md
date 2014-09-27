---
layout: post
title: How We Use Cucumber
comments: true
categories: software, cucumber
---
Lately I've been very involved in the conversion of our product requirements and
test scripts into executable documentation via Cucumber. We initially ran
into problems with deciding what goes into the feature files and what goes
into the step definitions. More than once we have had to stop and ask ourselves
if the feature files are too imperative or too high level. There was a lot of
back and forth until we settled on the following style.

### Feature File Writers Treat the System as a Black Box

A really black box with a UI that is constantly changing. In this
case, the feature file writer (business analyst) pretends at one point that
the system only accepts requests via mind control. At other times, she pretends
that the system is controlled via a physical requisition form (signed in
triplicate!). It may seem odd at first, but this way of thinking is actually
very helpful because it encourages the business analyst to write business
requirements rather than UI specs. Now we end up with short, readable, and
very clear feature files:

    Feature: Withdraw Cash

      Scenario Outline: Withdraw an amount given a balance
        Given my account has a balance of <Balance>
         When I withdraw <Requested Amount>
         Then the amount will be <Dispensed or Not>

        Scenarios:
          | Balance | Requested Amount | Dispensed or Not |
          |    $100 |              $50 | Dispensed        |
          |    $100 |             $150 | Not Dispensed    |

Notice how the above has only one `When` step and it doesn't even indicate
how the user withdraws the requested amount because, for all business analyst
knows, the system could be driven by robotic gherbils that take the details of
her request (as indicated in the `When` step) and manually pull levers to make things happen!

Requirements can even be shorter if the operation doesn't require any data.
For example:

    Scenario Outline: A user with a given role disables notifications
      Given I have a role of <Role> in the system
       Then I <Can or Cannot Disable> notifications

      Scenarios:
        | Role         | Can or Cannot Disable |
        | System Admin | Can Disable           |
        | User         | Cannot Disable        |

Notice how I didn't need to write a `When` step in the scenario outline,
yet the requirements are still very clear.

### Step Definitions are the Domain of the Testers

And these testers are the guys that build the robotic gherbils (otherwise known
as step definitions). One of the steps above could be defined as follows:

    Then /^I [Cc]an [Dd]isable notifications$/ do
      Notifier.fill_in 'username', 'jdoe'
      Notifier.fill_in 'password', '123qwe'
      Notifier.click   'login'
      Notifier.click   'disable'

      Notifier.should_be_disabled
    end

In the cash withdrawal example above, one of the steps could be defined as:

    When /^I withdraw $(\d+)$/ do |amount|
      Atm.insert_card

      # Enter PIN
      Atm.press_key '1'
      Atm.press_key '2'
      Atm.press_key '3'
      Atm.press_key 'OK'

      # Withdraw amount
      Atm.press_key 'Withdraw'
      Atm.fill_in   'Amount', amount
      Atm.press_key 'OK'
    end

Notice how the step definitions are tied to the solution, which implies
that this part only gets written after the team has decided on the UI design.

### Keeping Concerns Separate

Apart from the business analyst adopting a black box thinking, we also avoid
having testers initially write the feature files. This is because testers are
used to poking around the app which assumes that the app is already built.
Because this way of thinking is so ingrained in them, there is the risk of
feature files becoming tightly coupled with one solution.

### Parting Thoughts

Cucumber's flexibility seems to be both a boon and a curse to teams, especially
for those just learning about it. In our case, reading
[The Cucumber Book](http://pragprog.com/book/hwcuc/the-cucumber-book) and
[Specification by Example](http://specificationbyexample.com/) pointed us to
the right direction. Also, daily interaction with the helpful folks in the
[Cucumber mailing list](https://groups.google.com/forum/?fromgroups#!forum/cukes)
further helped us find the right way to use the tool.