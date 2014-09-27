---
layout: post
title: Analyzing Team Performance Using Trello Data
comments: true
categories: software development, trello, agile, analytics
---

**UPDATE 2014-04-24:** Code related to this post is now available in [Github](https://github.com/NexusIS/rosetta).

We've been using Trello exclusively at my new job for managing our tasks.
As an outsider, I'd say that the Trello team did a very good job
of identifying the application's core features and relentlessly
focusing on those. One of the features that I appreciate is how it
made creating and updating cards so easy and fast. As an agile developer
for over 5 years now, I've found that the lack of this feature is invariably
one of the things that stand in the way of a team fully adopting agile
practices. That's also what led me to write [Redmine Backlogs](http://www.redminebacklogs.net)
back in 2008.

## Measuring Team Agility

As they say, you can't manage what you can't measure. And while Trello comes
with some plug-ins that allow you to input story points and view burndown charts,
we needed something more detailed than that. We tried a few third party applications
but they just couldn't handle the corner cases of our process. So we decided it
was time for us to dig into the [Trello API](https://trello.com/docs/).
The rest of this post describes part of that adventure.

## Tracking a Card's Movement

We wanted to be able to see how much time a card spent in a list. In addition
to that, if a card moved to the latest sprint because it couldn't be completed in the
previous one (common in new teams or totally new stories/epics), then we wanted to
be able to track that information as well.

The first step was to create a card in a board and then use the [Postman plugin](https://chrome.google.com/webstore/detail/postman-rest-client-packa/fhbjgbiflinjbdggehcddcbncdddomop?hl=en)
for Chrome to query the API. Here's what I got when I queried the card's history:

{% highlight json linenos %}
    [
        {
            "id": "5346cccb6d6568eb4ca03073",
            "idMemberCreator": "5345929b303f8a7fqwerac0",
            "data": {
                "board": {
                    "shortLink": "mQVOH5k0",
                    "name": "TEST PRODUCT BACKLOG",
                    "id": "5346ccasdfkjaeb1464b9dceb"
                },
                "list": {
                    "name": "To Do",
                    "id": "5346ccbcd4744b1464b9dcec"
                },
                "card": {
                    "shortLink": "v821QEWS",
                    "idShort": 1,
                    "name": "TEST CARD 001",
                    "id": "5346cccb6vneo3hb4ca03072"
                }
            },
            "type": "createCard",
            "date": "2014-04-10T16:54:35.952Z",
            "memberCreator": {
                "id": "5345929b303f8a7fqwerac0",
                "avatarHash": "d5c154d0def75725660a62579b7a1e95",
                "fullName": "Check N. Orris",
                "initials": "CN",
                "username": "checknorris"
            }
        }
    ]
{% endhighlight %}

Here's the board's history

{%highlight json linenos %}
    [
        {
            "id": "5346cccb6d6568eb4ca03073",
            "idMemberCreator": "5345929b303f8a7fqwerac0",
            "data": {
                "board": {
                    "shortLink": "mQVOH5k0",
                    "name": "TEST PRODUCT BACKLOG",
                    "id": "5346ccasdfkjaeb1464b9dceb"
                },
                "list": {
                    "name": "To Do",
                    "id": "5346ccbcd4744b1464b9dcec"
                },
                "card": {
                    "shortLink": "v821QEWS",
                    "idShort": 1,
                    "name": "TEST CARD 001",
                    "id": "5346cccb6vneo3hb4ca03072"
                }
            },
            "type": "createCard",
            "date": "2014-04-10T16:54:35.952Z",
            "memberCreator": {
                "id": "5345929b303f8a7fqwerac0",
                "avatarHash": "d5c154d0def75725660a62579b7a1e95",
                "fullName": "Check N. Orris",
                "initials": "CN",
                "username": "checknorris"
            }
        }
    ]
{% endhighlight %}

The board's and card's history line up and it was all good. I then moved the
card to another list in the same board and the data that the API returned for
both the board and the card was still accurate. However, when I moved the card
to a different board, some weirdness happened. Here's the card's history (shortened
to relevant part):

{% highlight json linenos %}
    [
        {
            "id": "5346cccb6d6568eb4ca03073",
            "idMemberCreator": "5345929b303f8a7fqwerac0",
            "data": {
                "board": {
                    "name": "TEST SPRINT BACKLOG",
                    "id": "5346d0crikwj401130b30bde"
                },
                "list": {
                    "name": "To Do",
                    "id": "5346ccbcd4744b1464b9dcec"
                },
                "card": {
                    "shortLink": "v821QEWS",
                    "idShort": 1,
                    "name": "TEST CARD 001",
                    "id": "5346cccb6vneo3hb4ca03072"
                }
            },
            "type": "createCard",
            "date": "2014-04-10T16:54:35.952Z",
            "memberCreator": {
                "id": "5345929b303f8a7fqwerac0",
                "avatarHash": "d5c154d0def75725660a62579b7a1e95",
                "fullName": "Check N. Orris",
                "initials": "CN",
                "username": "checknorris"
            }
        }
    ]
{% endhighlight %}

Notice anything odd with the the createCard record's board name and ID? It says it
was created in TEST SPRINT BACKLOG when it was actually created in TEST PRODUCT
BACKLOG (see first card history code snippet above). In short, history was being
rewritten in the Trello cards. I contacted their customer support about this
and I got a prompt response from Brian who told me that it was not possible to
get the card's history from its original board because of how Trello's permission
model is currently implemented.

If your first reaction to that was "what?? that sucks!", I'm not going to blame you.
That was my first reaction too. I also wondered why, if I'm a member of the same board,
can't Trello just figure that out and display the history accordingly? Then I remembered
that one feature that I really appreciate about Trello which I will start calling Speed
of Use or SoU (trademarked!) from now on.

As I said earlier, I believe that SoU is a crucial factor in an agile software (in
any software, in fact!) and the Trello team likely identified this early on and decided
to use it as criterion for every feature or change request that comes their way. In the
case of a card's history, they likely had to choose between:

1. Fetching a card's complete history, determine which record belongs to which board,
   determine which board the current user has permissions in, and then selectively
   return records that the user can view. 100% accurate, but computationally expensive. Or...

2. Fetching a card's history in the current board. Replace the createCard data with the
   name and ID of the current board. Inaccurate, but computationally cheap.

They also probably remembered that Trello is [a horizontal product](http://www.joelonsoftware.com/items/2012/01/06.html)
and doesn't just cater to professional software teams or even professional teams but to
anyone who needs to manage a set of lists. Based on that, they probably decided that
option 2 was the best choice since that's probably good enough for 99% of their customers.
I agree with their choice. That's smart software design right there.

## Cool Study on Software Design. But What About Your Analytics?

The nice thing about being a data geek is that there's a high chance one is also a software
geek. After some digging into the API, I found that I can actually rebuild the card's history
by collating all relevant boards that I have permission in, matching that with
the card's history and conducting some further cleanup. Within a few hours, I had a script that
exported Trello data to a CSV file depicting the movement of cards across boards and lists.
Specifically:

* I can tell which list in which board a card started in

* When a card entered a list and when it left it

* Consequently, how much time a card spent in a list or a board

And that's just the raw data. I'm sure there so much more information one can glean from this.
Source is available at [Github](https://github.com/NexusIS/rosetta).
