---
layout: post
title: How We Use Cucumber, The Sequel
comments: true
categories: software, cucumber
---
In a [previous post](/2012/04/using-cucumber.html), I explained how we used Cucumber. Now, after about a month of using the recommended style, we've noticed some 'usability problems' and introduced our own styles.

### Readability of stepdefs
The following is how our steps used to be defined:

    Then /^I can disable notifications$/i do
      Notifier.fill_in 'username', 'jdoe'
      Notifier.fill_in 'password', '123qwe'
      Notifier.click   'login'
      Notifier.click   'disable'

      Notifier.should_be_disabled
    end

It's nice, clean, and readable...for a programmer. However, stepdefs are not exclusive to programmers: testers also need to be able to review them to know if the test is thorough or accurate. We have smart testers who know how to find edge cases or break an application, but they don't know how to code. Things like dot notation and remembering to enclose a string with quotations are alien to them. They already understand English though and since we found that it's easy to modify the above code to read like English, we thought it would be better to write stepdefs that the Testers can use within stepdefs. One example of such a stepdef is:

    Then /^Fill in the (.+) field with (.+)$/i do |field_name, value|
      field_name = field_name.split.join('_').downcase
      Notifier.fill_in field_name, value
    end

Now, the step listed at the top is defined like this:

    Then /^I can disable notifications$/i do
    steps %{

      * Fill in the Password field with 123qwe
      * Click the Login button
      * Click the Disable button

      * The Notifier should be disabled

    }
    end

Our testers still had to deal with regex and the `steps %{ }` delimiter, but that's a lot easier compared to the previous style. Now, their tests read a lot like the the test specs that they're used to.

### Fragmented test scripts and cognitive dissonance
One of the bigger pains that we've encountered is the fragmentation of our test scripts for a given scenario. For example, in the following:

    Scenario Outline: Withdraw an amount given a balance
        Given my account has a balance of <Balance>
         When I withdraw <Requested Amount>
         Then the amount will be <Dispensed or Not>

        Scenarios:
          | Balance | Requested Amount | Dispensed or Not |
          |    $100 |              $50 | Dispensed        |
          |    $100 |             $150 | Not Dispensed    |

We'd end up with our test script for the above outline distributed across the three steps (Given/When/Then). This results in a few problems:

 * Anyone who wants to review the test script will have to scroll up and down (sometimes even jump between stepdef files) just to understand how the scenario is being tested;
 * There would have to be some variable sharing between steps. This was a problem that grew with the size of the test suite. The more we wrote stuff, the harder it became to trace how a variable was defined.

Given these problems, we had to change some things drastically. Here's what we're currently experimenting with:

    Scenario Outline:
      * Given the account has a balance of <Balance>, the system will <Dispense or Not> <Requested Amount>

        Examples:
          | Balance | Requested Amount | Dispense or Not |
          |    $100 |              $50 | Dispense        |
          |    $200 |             $199 | Dispense        |
          |    $100 |             $150 | Not Dispense    |
          |    $200 |             $201 | Not Dispense    |

What we changed:

 * We only use one line for each requirement. This allows us to use pronouns such as it, he, she. For example: `* Given the ATM has $1000, it will...` as compared to `Given the ATM has $1000; Then the ATM will...`
 * We start the line with the '\*' keyword instead of Given/When/Then because sometimes they are not as expressive as other means. For example it's clear enough to write a requirement such as `* An amount containing letters is invalid`

Second, we rewrote the underlying stepdef as follows:

    TestCase /^If the account has a balance of (\d+), the system will dispense (\d+)$/i do |balance, requested_amount|

      Setup %{
        * Ensure my account has a balance of #{ balance }
      }

      Teardown %{
        * Reset my account to 0 when done
      }

      Script %{
        * Insert card into the slot
        * Press the 1, 2, 3, and 4 keys
        * Press the OK key
        * Press the Withdraw key
        * Enter the amount #{ requested_amount }
        * Press the OK key
        * The amount #{ requested_amount } should be dispensed
      }

    end

(We also created a separate stepdef for the 'Not Dispense' scenario)

What we changed:

 * We created an alias for 'Then/Given/When' called `TestCase` as this was more expressive of the block's intent
 * We also created the keywords `Setup`, `Teardown`, and `Script` which are just aliases for `steps` as it was more expressive of what each block is for.
 * The filenames for TestCase files are now \*\_test_cases.rb instead of \*\_steps.rb
 * Each test case is self contained. Meaning it doesn't share any instance variables with other test cases.

Finally, we created a separate directory for all the steps used in the above test case. So now our features directory looks like this:

    features/
     |
     |- requirements/
     |   |
     |   |- withdrawal/
     |   |   |
     |   |   `- withdraw_amount.feature
     |   |
     |   `- deposit/
     |
     |- test_cases/
     |   |
     |   |- withdrawal_test_cases.rb
     |   |
     |   `- desposit_test_cases.rb
     |
     |- utilities/
     |   |
     |   |- functions/
     |   |
     |   `- steps/
     |       |
     |       |- accounts_steps.rb
     |       |
     |       |- atm_steps.rb
     |       |
     |       `- web_steps.rb
     |
     `- support/

The above structure is complemented with the following conventions:

 * Files in the `requirements` directory may use any test case that's defined in the `test_cases` directory. They may not use anything outside of that directory.
 * Files in the `test_cases` directory may use anything in the `utilities` directory. They may not use anything outside of that directory.
 * Files in the `utilities` directory may use anything that's in the `support` directory. They may not use anything outside of that directory.

### Results so far
I understand that this approach has diverged from the Cucumber community's accepted practice, however, the results so far have been very promising:

 * The requirements read more like requirements and are more succinct
 * The test script for a given requirement is found in a single test case located in a single test cases file
 * Perhaps the biggest potential win so from this is that BAs, Testers, and Devs can collaborate better because the test cases are easier to read and follow. Now BAs can talk to a Tester to ask why a certain requirement was tested this or that way, Testers can also talk to Devs to ask why a certain requirement failed considering that they tested it this or that way.

### Conclusion
As I mentioned above, I'm aware that this is a significant divergence from generally accepted Cucumber practice (In fact this is more influenced by the Robot Framework than Cucumber) so we're taking it slowly to see if there's a catch. Overall though, we feel good about this new direction.

**UPDATE** I started working on a prototype framework that better supports what I'm trying to achieve. It's tentatively named [<del>Norm</del>](https://github.com/norm-framework/p4) [ManaMana](https://github.com/ManaManaFramework/manamana).
