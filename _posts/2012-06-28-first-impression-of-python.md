---
layout: post
title: First impression of Python
comments: true
categories: software, python
---
I've started learning about Python during my free time and one of the things
that bothers me is the fact that I have to use the len() function on an object
instead of just calling a length method on that object. I've read the 
discussions online about this (e.g. [1](http://effbot.org/pyfaq/why-does-python-use-methods-for-some-functionality-e-g-list-index-but-functions-for-other-e-g-len-list.htm), 
[2](http://stackoverflow.com/questions/237128/is-there-a-reason-python-strings-dont-have-a-string-length-method), [3](http://lucumr.pocoo.org/2011/7/9/python-and-pola/)) and my attempt
to summarize the justifications are as follows:

 1. len() has better clarity of intent
 1. 'length' has a different meaning for different objects
 1. That's how it's always been from the beginning

I'm not convinced at all by reason #1. Compare the following:

      len(full_name)
  
      full_name.length

I'd say both have the same level of clarity. Both versions clearly say that we're
trying to get the length of full_name.

Reason #2 which I summed up from [here](http://lucumr.pocoo.org/2011/7/9/python-and-pola/), 
on the other hand, is irrelevant. Let me first quote an excerpt from that page:

> Also just because something responds to .size does not mean it's a collection 
> with a size. For instance integers have a .size attribute but no .length. And 
> the size is the number of bytes used to store that number.

Let me paraphrase the above:

> Also just because something responds to .length does not mean it's a string with
> a length. For example, an instance of TelephoneCable has a .length attribute...
> and the length is its length in meters.

Why does that even matter when Python espouses dynamic typing which basically means the object's
underlying data type is less important than the operations we can do with that object. So
we shouldn't have to care if the object is a string or another object. For as long
as we know that we can call `length` on it, then that's fine. Consider the following:

      car.length
      full_name.length
      cable.length

In the above examples, do we really care what the underlying types are? No. What
we care about is that we can call `length` on them and that we will get back a numeric value.

Reason #3 is a more acceptable answer and should really be the first reason that
any len() apologist should offer. It's not a very good reason, but it's a whole 
lot better than the first two.

Having said that, I will stick to this Python convention anyway. I have way too much
experience trying to adopt a convention from one language to another (e.g. using Ruby
conventions in Javascript) and it often produces even uglier code.

BONUS: [What Pythonistas think of Ruby](http://peepcode.com/blog/2010/what-pythonistas-think-of-ruby)