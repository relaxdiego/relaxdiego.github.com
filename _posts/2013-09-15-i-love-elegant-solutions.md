---
layout: post
title: I Love Elegant Solutions
comments: true
categories: software development, algorithms
---
Last week while I was playing around with ManaMana's self-testing capability, I came across a problem where I needed the RDSL syntax to allow for preformatted blocks in requirements such as the following:

    * A Wiki page displays the following text
      ```
      Dear World,
         Hello!
      ```
      when it is newly generated.

Modifying the RDSL lexer to recognize the preformatted blocks was the easy part. The problem after that was how do I strip whitespace in the requirements while preserving it inside the preformatted blocks? Initially, I thought about the following process:

1. Use regexp matching to capture the blocks
1. Somehow memorize their position in the requirement string
1. Replace the blocks in the string with placeholders
1. Remove all whitespace in the string
1. Replace the placeholders with the original blocks
1. Replace lost hairstrands after coding this
  
I was not convinced. I'm glad I didn't settle for it because then I discovered this solution.

1. Split the string by the &#96;&#96;&#96; delimiter
1. Odd array elements (indices 1, 3, 5, ...) will always be preformatted blocks
1. Remove all whitespace in the even elements (indices 0, 2, 4, ...)
1. Join the array with spaces

Here's [the final code](https://github.com/ManaManaFramework/manamana/blob/master/src/rdsl/lexer.rl#L61).

## Postscript

Going off on a bit of a tangent here, but I'm not sure though if this is the best way to process preformatted blocks because, with this method, they are not first-class tokens and, thus, not recognized by the parser. Having the parser recognize them would probably be nice as it allows for syntax checking. I haven't thought this one through as much as I think I should though. We'll see.