---
layout: post
title: A Workflow Using Cucumber
comments: true
categories: software, cucumber
published: false
---
# A Workflow Using Cucumber

At my place of work, we've found an ideal way to use Cucumber that makes it effective and doesn't produce bad cukes. Here's how we do it.

## Business Analysts Own The Feature Files

I've read a number of comments in the past how the Gherkin syntax is so easy that anyone can write feature files. I even read about one guy who mandated that **everyone** in the company write feature files. I don't know how that turned out but from our own experience, that never worked out well if at all. That's probably because, in an organization, ever individual always has more important things to do than write feature files. Let's face it, while Gherkin is a very readable language, it still imposes a certain rigid structure that gets in the way of transmitting one's thoughts in a fluid way. Humans aren't used to talking in Given, When, and Then sentences. They blurt things out off the top of their head and hash it out with their collegues. Thus it's always easier for them to fire up their mail or IM client and talk to the team about what they want to happen.

For this reason, we assign a feature file to a business analyst who is responsible for converting the braindumps from stakeholders into structured text. It's not a one way street though: as the BA receives the comments from stakeholders, she asks for clarifications and even suggest alternatives should the requirement turn out to conflict with an existing one.

There is one other reason why the BAs are important in the process: they have been trained on the correct way to write feature files. I already mentioned how they write feature files in [a previous post](/2012/04/using-cucumber.html), but the gist of it is that the BAs treat the system's UI as if it was constantly changing. That way, they focus on writing business requirements rather than UI specs. An example:

    Feature: Withdraw Cash

      Scenario Outline: Withdraw an amount given a balance
        Given my account has a balance of <Balance>
         When I withdraw <Requested Amount>
         Then the amount will be <Dispensed or Not>

        Scenarios:
          | Balance | Requested Amount | Dispensed or Not |
          |    $100 |              $50 | Dispensed        |
          |    $100 |             $150 | Not Dispensed    |

Notice how the `When` step doesn't say how the user withdraws the amount: no "When I click this" or "When I insert that." This has a number of advantages including:

1. Feature files focus on the business requirements, making it very readable to the stakeholders.
1. The implementing team has the freedom to experiment on different UI solutions to fulfill the requirement.

## Testers Own The Step Definitions