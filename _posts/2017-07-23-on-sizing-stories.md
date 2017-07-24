---
layout: post
title: On Sizing Stories
comments: true
categories: agile, scrum, sizing, stories, planning, planning poker
---

Let's take a quick break from coding and talk about planning in a Scrum-based
team. Specifically, let's talk about sizing or assigning points to stories.

Even after more than 8 years\* of practicing Scrum, I still encounter teams who 
find it hard to grasp the idea of story points and, unfortunately, fall back 
to the old ways of equating a point to a certain number of hours or days. I 
can't blame them though because, when I was just starting with Scrum, I've read
so many conflicting publications on this topic and, combined with all the other
"alien" concepts introduced by Agile, it took a while to wrap my head around it.
The "aha!" moment for me happened after I read [this book](https://pragprog.com/book/jtrap/the-agile-samurai)
and what I'm about to share below is largely based off of that.

## Let's Talk About Cookies

No, not browser cookies. I'm talking about the delicious (yet just as evil) type:

![Nom nom nom nom](/assets/images/cookie.jpg)
<center>Source: https://commons.wikimedia.org/wiki/File:Pepperidge-Farm-Nantucket-Cookie.jpg</center>

### Scenario 1: A Perfect Stack of Cookies!

Let's pretend that we need to estimate how long it'll take to eat a stack of 
equally-sized cookies. Let's also say that we have no other information available
to us other than the number of cookies in the stack. Let's say there's 100
uncannilly-equally-sized (accurate to 0.01mm!) cookies in that stack.

How can we estimate how long it will take to finish the stack? Do we spend an
inordiate amount of time guessing, conjecturing, padding, and re-guessing? Or
do we just take out a stopwatch and measure how long it takes to eat 3~4 cookies?

To me, the second option seems more practical (and enjoyable!) and 
will most likely give us the most accurate estimate in the shortest amount of 
time. Within a few minutes, we'll have our velocity in terms of Cookies Per 
Minute (CPM) and we can compute how long it will take to finish the entire 
stack via:

> **(100 Cookies) / (y Cookies Per Minute) = z Minutes**

### Scenario 2: A Second Stack of Cookies???!

Now let's pretend the cookie gods really like us and they gave us a second
stack of cookies but, this time, the cookies are **unequally** sized. Would
the formula we derived in the previous scenario still work? Probably not because
the size differences will introduce some level of error. Now let's pretend that
the size differences are so significant (some are 10x bigger!) that we simply
can't ignore that fact. How can we estimate in this case?


<center>Can we call a friend?</center>
![Cooooookie](/assets/images/cookie-monster.jpg)
<center>Source: Michael Verhoef https://www.flickr.com/photos/nettsu/4167860394</center>

<center>&nbsp;</center>

We don't need to call Cookie Monster. All we need to do is size each
cookie in this second stack relative to the standard cookie size that we'll derive
from the first stack (remember, all cookies in the first stack are equally sized 
with an accuracy of 0.01 mm!). For example, if we pick a cookie from the second 
stack and find that it's about 1.5 times heavier than a cookie from the first stack, 
then we can say that the cookie we just picked from the second stack is equivalent 
to 1.5 standard cookie size. 

Let's start calling the standard cookie size a **Cookie Point** from here on out.

We'll do this for every cookie in the second stack until they've all been sized. 
We then sum the the Cookie Points of the second stack (let's refer to that sum 
as `x`) and plug it into our formula as follows:

> **(x Cookie Points) / (y Cookie Points Per Minute) = z Minutes**

We're still using the same formula but instead of using 100 for the dividend,
we replace it with `x` which is the relative weight of the second stack compared
to the first stack. As for the divisor, since 1 (standard) Cookie equals 1
Cookie Point, it's still the same as in the first version of our formula.


### Scenario 3: Hey, Who Moved My Cookie???!

Now let's reset everything and pretend that we never had the first stack to
begin with. That means we don't have a standard cookie size and, therefore, 
we don't have anything to compare our stack of unequally-sized cookies against. 
How will we be able to relatively size the stack in this case?

Easy: just choose an arbitrary cookie from the stack and call that the standard
cookie size. Next, just size the other cookies in the stack relative to the 
one you just designated as the standard. 

Note, however, that after you've gone through all the cookies in the stack, 
you're not done yet. Remember that, in this scenario, we reset everything and
that means we also don't have any **Cookie Points Per Minute (CPPM)** data. So 
how do we get that in this case?

Just like before, take out your stopwatch and start eating! After eating 
a few of these unequally-sized cookies, you'll have your CPPM value and you 
can stick it into the formula again:


> **(x Cookie Points) / (y Cookie Points Per Minute) = z Minutes**


## Let's Apply What We Learned To Story Sizing

From the above scenarios, #3 is typically where most Scrum teams will fall in:
they'll have a backlog of stories with varying sizes and they don't have a 
standard story size to compare them against.

To pick a "standard story size," we'll follow a similar process as in the 3rd 
scenario but we'll add a few more steps in the mix. Specifically:

1. Have the team pick a story from the backlog;
2. Next, have the team ask the product owner questions about the story;
3. Afterwards, the team lists down the subtasks that they think will need to be 
   done to complete story. This will help them get a good enough feel for its 
   complexity;
4. The team then gives it a score of 3. This will be the reference story or 
   "reference cookie" by which all other stories will be measured against.
   Why 3? Because if we give it a 1 and we later find a smaller story, 
   we'll have no choice but to assign that smaller story a decimal value.
   This can result in decimal nitpicking which will just hamper
   rather than facilitate the exercise. So choose a 3 (If you're using Fibonnaci),
   or any other middle-of-the-road value in your whole-values-only sequence and
   avoid decimals like the plague.

Have the team repeat the above process for other stories except that, in step 4,
instead of assigning the story a 3, the team should use planning poker to give 
it a size relative to their reference 3-pointer story.

IMPORTANT: Always bring the team's attention back to the first story you sized 
as a 3. Having that story to compare against will help them size each subsequent
story faster.

If there is a large deviation among team members when sizing a story, have
those on either ends of the spectrum explain why they chose what they chose then
have the team repeat the scoring exercise. Normally, the story points will have
converged by the second attempt. If the story points still didn't converge, 
pick the score with the most votes. There's no need to over-analyze it. Settle 
it quickly and move on to the next.

By the end of the above exercise, you'll have a set of stories that have been 
sized or weighted accordingly and if this is the first sprint planning session, 
you'll likely won't have any data on the team's velocity (or, in cookie-speak, 
the Cookie Points Per Minute). So, you won't have everything you need for the 
following formula.

> **(x Points) / (y Points Per Sprint) = z Sprints**

Specifically, you won't have `y` and, thus, won't be able to determine how many
sprints it will take to finish part or all of your product backlog.

So what do we do? As with scenario #3, just start working! By the end
of the current sprint, you'll have one data point which is good enough to use
as for `y`. As more sprints go by, you should keep maintaining an "average story 
points per sprint" value based on the last N sprints. Use the last N sprints 
and not all past sprints to compute this average because the older the sprint 
is, the less effective it is at predicting future performance (due to changes 
in team composition, available technology, etc)


## Don't Overload The Meaning of "Points!"

After a few sprints, you'll be tempted to equate a certain number of points to
a certain number of days. Don't. You're overloading the meaning of the word and
you'll cause confusion among team members because now they will not only have 
to think about how complex the story is but also translate that to a time value.

Keep it simple: let the meaning of "points" just be "how complex is this story
to implement?" Don't delegate the task of measuring possible release dates to
the team because that's your job as scrum master (or, in some cases, product 
owner) and the team already has enough technical matters to think about in its 
collective brain.


## Well, That's It!

Hopefully, that cleared some things for you in terms of story sizing. If not,
there's a link at the bottom of this page which will allow you to file a bug or
question against this post.

---------

\* - Wow how time flies! I did a quick check of [Redmine Backlogs](https://github.com/backlogs/redmine_backlogs/graphs/contributors), 
an open source project that I started back in the day when I was still using
[Redmine](http://www.redmine.org/), and realized it's been that long! Adding the work that I did for 
earlier unreleased versions of this project, I'd say I probably started early 2009 or 
late 2008 with Scrum/Kanban/Agile.
