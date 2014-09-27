---
layout: post
title: Writing a Compiler (Part 2)
comments: true
categories: Programming, Ruby, Compiler, Ragel, Racc
published: false
---
_This is part 2 of a series of posts where I talk about how I wrote compilers for two languages that I designed. You can see part 1 [here](/2012/07/writing-a-compiler-1.html)._

[Previously](/2012/07/writing-a-compiler-1.html), I talked about how lexers and parsers work together to compile a source file into something executable. In this installment, I'll get more concrete by talking about how to write a lexer and parser.

## Writing a Lexer

As I mentioned in my previous post, a lexer is just a state machine that scans a source file from start to finish and generates a series of tokens based on the patterns that it encounters. These tokens will then serve as input to the parser which we will talk about later.

We could write our lexer from scratch using Ruby, Python, etc, and it wouldn't be hard, at least at the beginning. As we start adding more features to our language, however, maintaining such a lexer becomes more complex as we add more pattern recognition logic. That's why we need to use a specialized tool for building it. Luckily there a number of tools at our disposal. These include [Lex](http://en.wikipedia.org/wiki/Lex_programming_tool), [Flex](http://flex.sourceforge.net), [Rexical](https://github.com/tenderlove/rexical), and [Ragel](http://www.complang.org/ragel/). In our case, we'll use Ragel because it's the one I'm familiar with.

## Ragel

Ragel is an impressive tool not just because of its flexible and expressive syntax, but also because it can actually output a lexer to any target language using the same grammar file. This means that you can use Ragel to create lexers that are written in C, C++, Objective-C, D, Java and Ruby. For this post, we'll use Ragel to create a lexer written in Ruby.

Let's revisit our source file written in a hypothetical language called "ToDo":

    For: 2012-01-31
      - Buy fireworks
      - Buy champagne
      - Party!
    For: 2012-01-01
      - Recover from hangover

What we want to do is create a lexer that takes the above as input and produces the following:

    [['TODOLIST', '2012-01-31'],['ITEM', 'Buy fireworks'],['ITEM', 'Buy champagne'],['ITEM', 'Party!'],['TODOLIST', '2012-01-01'],['ITEM', 'Recover from hangover']]

## Programming with Ragel

As mentioned, Ragel is a tool that allows you to define a state machine and then compile that definition into your target language. For our ToDo lexer, the source file that we supply to Ragel would have the following structure:

    =begin
    %%{

      <State machine definition here>

    }%%
    =end

    <Ruby code with embedded Ragel code>

When we process this using the Ragel CLI, a file will be produced with all Ragel code translated to Ruby. Here's an example from one of my earlier projects: [Ragel source](https://github.com/norm-framework/p4/blob/master/src/ba_speak/lexer.rl), [Resulting Ruby code](https://github.com/norm-framework/p4/blob/master/lib/ba_speak/lexer.rb).

The state machine definition section of our lexer will look like this:

    =begin
    %%{

      machine lexer;

      list_name = "For: " digit{4} "-" digit{2} "-" digit{2};
      item_name = " - " print*;

      main := |*

        list_name  => { emit_list_name(token_array, data, ts, te)  };
        item_name  => { emit_item(token_array, data, ts, te)       };

        space;

      *|;
    }%%
    =end

There are a number of things going on here so we'll take it step by step. Firstly, the following line:

    machine lexer;

That just tells Ragel that we are about to define a new state machine (Remember that lexers are really just another form of a state machine). This is required in Ragel and the reason for that is because Ragel allows you to combine different state machines in one or more files which is good to know even though, for this example, we're not going to use our lexer state machine outside of this file.

The next two lines define two variables that will be used within our lexer definition:

    list_name = "For: " digit{4} "-" digit{2} "-" digit{2};
    item_name = " - " print*;

The first variable, `list_name`, is assigned a pattern that matches a todo list's name and it starts with a string literal "For: " immediately followed by 4 digits which is, in turn, immediate followed by a string literal "-" and so on. Note a couple of things in this pattern definition: 1) a space is used to concatenate two patterns in Ragel and 2) the `digit` identifer is one of a few built-in simple patterns that you can use when building more complex patterns.

The second variable, `item_name`, is assigned an even simpler pattern that matches an item in a todo list. It starts with a string literal "-" followed by one or more printable characters;

  NOTE: `list_name` and `item_name` are more formally known as machines which are composed of other simpler machines, but for the purpose of this post, calling them "patterns" may be easier to understand which is why I use the latter instead.

