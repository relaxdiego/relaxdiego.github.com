---
layout: post
title: Writing a Compiler (Part 1)
comments: true
categories: Programming, Ruby, Compiler, Ragel, Racc
---
This is the first in a series of posts where I will talk about how I wrote compilers for two languages that I designed. These languages, namely "BA Speak" and "QA Speak", are external domain-specific languages (DSL). They are DSLs because they have a very specific usage and are not general purpose languages. They are external because they are not constrained by the syntax rules of a host language.

## About BA Speak and QA Speak

BA Speak and QA Speak are DSLs that I created for a prototype framework I call Norm Framework. You can see the various prototypes of this framework [here](https://github.com/norm-framework). Norm was inspired by [Cucumber](http://cukes.info) and the [Robot Framework](http://code.google.com/p/robotframework/) which are automated acceptance test frameworks used for verifying a piece of software against a set of specifications.

BA Speak is used for writing software requirements and is meant to be readable even for non-technical individuals. Here's a sample requirement file written in BA Speak:

    Create Tickets
    ==============

      * A user who has a role of <Role Name>
        <Can or Cannot Create> tickets in it

        Examples:
          | Role Name | Can or Cannot Create |
          |-----------|----------------------|
          | Manager   | Can Create           |
          | Member    | Can Create           |
          | Guest     | Cannot Create        |

        Notes:
          Arbitrary text that the business analyst or domain expert
          thinks might help the development team understand the
          problem much better. Blah blah blah.

      * Newly created tickets have a status of 'Active'

While the above example reads like English, you are not limited to it. You can use any human language you prefer.

As for QA Speak, you use it to write the test scripts for each of the above requirements. For instance, the test case for the last requirement above might be written as follows:

    Test Case:
      Newly created tickets have a status of '(.+)'

      Variables:
        * Status      = $1
        * My Username = 'Bob'
        * My Password = '123qwe'

      Preconditions:
        * An account with username <My Username> and password <My Password> exists
        * I am logged in as <My Username>

      Cleanup:
        * Delete the account with username <My Username> at exit

      Script:
        * Click the 'New Ticket' button
        * Fill in 'Ticket Name' with 'Test ticket'
        * Click the 'Submit' button
        * The ticket named 'Test ticket' should have a status of <Status>

What the Norm Framework does is take these source files compile them to Ruby, combine them, and then translate them into [MiniTest](http://docs.seattlerb.org/minitest/) specs.

## Tools Used

I used the following tools for building my compilers. If you're not familiar with the lexer and parser concepts, don't worry. I talk about them briefly in the next section.

* [Ruby](http://www.ruby-lang.org) - This is my target language. Meaning my "BA Speak" and "QA Speak" languages are ultimately compiled to Ruby code.
* [Ragel](http://www.complang.org/ragel/) - Ragel is a state machine compiler and since lexers/tokenizers are just state machines, I used Ragel to create the lexers for both languages. I could've written my tokenizers using Ruby directly, but it wouldn't have been as expressive. Believe me, I tried!
* [Racc](http://i.loveruby.net/en/man/racc/usage.html) - I used this to create the parser for both languages.

## Lexers and Parsers

Compilers are simply tools that translate a source file from one language to another. For example, a typical C compiler transforms your .c files to assembly or machine language. In my case, I created a compiler that transforms BA Speak and QA Speak source files into Ruby code.

To do this, we need to go through a 2-step process: lexing (aka tokenizing) and parsing. You can try and combine these into a single step, but I find that it results in really messy code. You will see this mess in one of [my prototypes](https://github.com/norm-framework/p2/blob/master/lib/requirement_translator.rb).

Now, there are whole courses in schools dedicated to the discussion and understanding of lexers and parsers, but I will try to explain them in my own simplistic way that may be insufficient for designing more complex languages, but will be enough for the purposes of this blog post.

Tokenizers and parsers actually have very similar functions: they take a set of "things" (characters, tokens, etc.) and group, mark, or organize them according to the rules of the language. The difference between tokenizers and parsers is in the level that they operate. This becomes much easier to understand with an example. Let's say we have the following source file written in some specialized language called "ToDo":

    For: 2012-01-31
      - Buy fireworks
      - Buy champagne
      - Party!
    For: 2012-01-01
      - Recover from hangover

When we run that through the ToDo tokenizer, it might produce an array of tokens as follows:

    [['TODOLIST', '2012-01-31'],['ITEM', 'Buy fireworks'],['ITEM', 'Buy champagne'],['ITEM', 'Party!'],['TODOLIST', '2012-01-01'],['ITEM', 'Recover from hangover']]

So what the tokenizer does is take the source file and create tokens based on the sequence of characters it encounters. In the above example, it recognizes a string of characters that start with "For: " followed by a date format and creates a TODOLIST token based on that string. If the "For:" line contained any extra whitespaces, the tokenizer would silently strip those. It does this character sequence recognition task until it reaches the end of the file. One thing you'll notice from the tokenizer's output is that it's flat. That is, there's no hierarchy to it. Also, if we'd written a Todo Item outside of a Todo List, the tokenizer would still happily create a token for that. So aside from flat hierarchy, the tokenizer also doesn't have any grammar checks. That's where the parser comes in.

If the tokenizer's job is to simply recognize sequence of characters and create the equivalent token for it, the parser's job is to check if the sequence of tokens complies with the ToDo language's grammatical rules (which are defined inside the parser) and then produces the appropriate hierarchical code in the target language. For example, passing the above set of tokens through the ToDo parser might result in the following code (Ruby in this case):

    root_node = RootNode.new([
                  TodoListNode.new('2012-01-31', [
                    ItemNode.new('Buy fireworks'),
                    ItemNode.new('Buy champagne'),
                    ItemNode.new('Party!')
                  ]),
                  TodoListNode.new('2012-01-01', [
                    ItemNode.new('Recover from hangover')
                  ])
                ])
    root_node.run

Since the parser outputs Ruby code in this case, then the definitions of each node type above can be written using ordinary Ruby code. For instance, we could define RootNode as follows:

    class RootNode
      attr_reader :lists

      def initialize(lists)
        @lists = lists
      end

      def run
        lists.each do |list|
          list.show if list.due_today?
        end
      end
    end

## Wrapping up for now

The most basic concept of lexers and parsers are not too hard to understand. As you can see above, they work together to make sense of a source file before transforming it into the target language. In the next part, I'll talk about how I applied this knowledge to create the "BA Speak" and "QA Speak" languages
