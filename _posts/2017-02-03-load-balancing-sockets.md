---
layout: post
title: Load Balancing Sockets
comments: true
categories: ruby, preforking, load balance, unix, sockets
---

If you need to write a service or agent that can cater to multiple
requests in parallel coming in from a single socket, you want to have
multiple subprocesses ready to cater to those requests in parallel.
But the question now is how do you ensure the requests are load balanced
across those subprocesses? Do you build a "Master" process that takes
care of load balancing, handing off those requests to the subprocesses
as needed?

No. No, you don't have to.

Just use the kernel's built-in ability to do that for you for free by
using the pre-forking method.

## An Example

The Ruby code below demonstrates how to take advantage of the kernel's
pre-forking model. Note that while it's written in Ruby, the same method
can be used in other languages since Ruby is really just making system
calls underneath all of that.

{%highlight ruby linenos%}
#!/usr/bin/env ruby

require 'socket'

# Open a socket
socket = TCPServer.open('0.0.0.0', 8080)

# Forward any relevant signals to the child processes.
[:INT, :QUIT].each do |signal|
  Signal.trap(signal) {
    wpids.each { |wpid| Process.kill(signal, wpid) }
  }
end

# For keeping track of children pids
wpids = []

5.times {
  wpids << fork do
    loop {
      connection = socket.accept
      connection.puts "Hello from #{ Process.pid }"
      connection.close
    }
  end
}

Process.waitall
{%endhighlight%}

Let's take this step by step:

* **Line 6**: Open up a single TCP socket in the parent process
* **Lines 9 to 13**: Trap the `:INT` and `:QUIT` signals in the parent process
  so that it can pass it on to its children
* **Lines 18 to 26**: Create 5 children and start accepting connections from
  the socket we opened in line 6. Note how, in line 22, we're sending back a 
  message along with the child's pid so we'll know who our client is talking to.
* **Line 28**: Make the parent process wait until all children have exited


## Run It!

* In one shell session, run this server using Ruby (e.g. `ruby server.rb`). 
* In a separate shell session, run the following:

```
for i in {1..10}; do nc localhost 8080; done
```

You should get 10 responses with varying process IDs in the message.

```
Hello from 93308
Hello from 93309
Hello from 93312
Hello from 93311
Hello from 93310
Hello from 93309
Hello from 93308
Hello from 93312
Hello from 93311
Hello from 93310
```


## So What's So Cool About This?

With this knowledge in hand, you'll avoid re-inventing the wheel in case
you want to create a node agent or a service where horizontal scaling doesn't
make sense because while this example is written in Ruby, it's really just
making system calls to the underlying \*NIX kernel and that means you can
get socket load balancing for free whichever programming language you choose!


## Acknowledgements

The sample code above was adapted from Jesse Storimer's book titled
[Working With UNIX Processes](http://www.jstorimer.com/products/working-with-unix-processes). Go buy that book. It's awesome!
