---
layout: post
title: Securely Syncing Sensitive Stuff
comments: true
categories: software development, ssl, security, silliness
---
So here was a fun little problem I tackled recently-ish. I needed my
code to send sensitive data from one host to another over TCP sockets
and there was no guarantee that either host had an SSL certificate that
was signed by a known provider. That means they will, more than likely,
be using self-signed certificates.

I'm getting ahead of myself. Let's back up a bit. If you were to connect
from one host to another over plain TCP sockets to download data like so:

[image]

Then the only proper response to that would be:

[image]

Because the data will be sent over the network in unencrypted. It's like
passing notes across the classroom: any person between sender and receiver
can view or even modify the message.

[image]

So we need to encrypt the data before it goes out into the wire.

The simplest solution would be to provide an encryption key to each host
and they can use that to encrypt and decrypt the data. The principle is
pretty much the same one used by [a cipher wheel](http://www.topspysecrets.com/secret-codes-for-kids.html).
The problem with this though is that you'd have to generate the key at
coding time, which would mean that the key would be visible in the source
code. That's not a very effective security measure: you want it such that
not even the developers know what the key is.
