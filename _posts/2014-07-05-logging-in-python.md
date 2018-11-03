---
layout: post
title: Hiding Sensitive Data from Logs with Python
comments: true
categories: Python, Logging, Filtering, Custom
---
<sup>Co-Written by [Hari Dara](https://github.com/haridsv)</sup>
<sup>Small code fix by [uenz](https://github.com/uenz)</sup>
Last week I've had to wrangle with Python's documentation because I needed one
of the apps I'm writing to centrally remove sensitive information from the logs. After
several attempts at understanding the documentation, I've come to appreciate
the built-in logging framework. I also have to admit that it's more powerful
than Ruby's built in logger.

There are definitely more than one approach to solve this problem, but I will discuss a couple of approaches below:
- [Using a filter](#redacting-logs-using-a-filter)
- [Using a custom formatter](#redacting-logs-using-a-custom-formatter)

## Creating a logger

To create a logger, use the class method (aka module-level function)
`logging.gettLogger()`. For example:

{% highlight python linenos %}
import logging

logger = logging.getLogger("myapp")
{% endhighlight %}

This creates a logging object named "myapp". Calling this same line from
anywhere in your application will return the same logging object. You can
also create hierarchies by separating names using dot notation. For example:

{% highlight python linenos %}
import logging

logger = logging.getLogger("myapp.my_object")
{% endhighlight %}

Creates a logger that is a descendant of the "myapp" logger we created above.
This is handy and allows you to just say `logging.getLogger(__name__)` in your
modules and they will be organized automatically.

After you've created your logger, creating log entries is similar to other
logging frameworks:

{% highlight python linenos %}
logger.debug("OHAI, I CAN HAZ DEBUG MSG?")
logger.info("I'M IN UR LOGGER. INFOING LOGS")
logger.warning("YOU HAZ RIGHT TO REMAIN SILENT")
logger.error("ERROR MSGZ")
logger.critical("OH NOEZ!")
{% endhighlight %}

More [where that came from](https://docs.python.org/2/library/logging.html).

## Configuring your loggers

There are different ways to centrally configure your application's logs, but I
prefer to use YAML. For example:

{% highlight yaml linenos %}
version: 1
disable_existing_loggers: False

formatters:
  simple:
    format: '%(asctime)s  %(name)-30s %(levelname)-7s %(message)s'

handlers:
    file:
        class: logging.handlers.RotatingFileHandler
        formatter: simple
        filename: /var/log/myapp/myapp.log

root:
    level: DEBUG
    handlers:
        - file

{% endhighlight %}

Let's break this down:

1. `version` tells the logging framework what configuration file schema version we're using.
1. `disable_existing_loggers` tells the framework what to do with loggers that were created before we configured it
1. `formatters` defines the formatters that we later use in the config file. The variables in the `format` key are actually attributes of the [LogRecord class](https://docs.python.org/2/library/logging.html#logrecord-attributes). The `30s` and `7s` suffixes tell the formatter the minimum number of chars to allocate to the string. Handy for lining up your entries.
1. `handlers` declares and configures the handlers that we want to use with our loggers. In this example, we have a handler named `file` which uses the built in [RotatingFileHandler](https://docs.python.org/2/library/logging.handlers.html#rotatingfilehandler) class.
1. Notice how we associated our `simple` formatter with our `file` handler in line 11?
1. Finally, we define our root logger which is the ancestor of all loggers we will create from here onwards. We set it to log from levels `DEBUG` and up and also specify that it use our `file` handler.
1. Alternatively, you could define other loggers here such as `myapp` and use the same method that we used with `root` to configure it.
1. Notice how, in our `root` logger we have `handlers` (plural)? That means we can add as many handlers as we want here.

Before we can use this YAML file though, we have to convert it into a dictionary
so that Python's logging framework can understand it. Simple enough. Let assume we
have a `configure_logging.py` file with the following contents:

{% highlight python linenos %}
import logging
import logging.config
import yaml

with open("path/to/yaml", 'r') as the_file:
    config_dict = yaml.load(the_file)

logging.config.dictConfig(config_dict)
{% endhighlight %}

After that, calling `logging.getLogger()` from anywhere in your app will give you
a logger configured as the above.

## Redacting logs using a Filter

Here's a [detailed flowchart](https://docs.python.org/2/howto/logging.html#logging-flow)
of how the logging framework handles log messages. The handler flow on the right side
gives us our first hint on how to centrally filter out sensitive information
from our logs.

Declaring a filter requires that we create a new section in our config file called
`filters` like so:

{% highlight yaml linenos %}
filters:
    myfilter:
        (): filters.RedactingFilter
        patterns:
            - "filterthisstring"
            - "thistoo"
            - "metoo!"
{% endhighlight %}

I declared only one filter there and the class name is `RedactingFilter` as indicated
by the `()` key. All other keys will be supplied to the `RedactingFilter` constructor. In
the above example, an array of strings called `patterns` will be passed. Let's
see how the `RedactingFilter` class might be defined. Let's assume we have a `filters.py`
file with the following contents:

{% highlight python linenos %}

import logging


class RedactingFilter(logging.Filter):

    def __init__(self, patterns):
        super(RedactingFilter, self).__init__()
        self._patterns = patterns

    def filter(self, record):
        record.msg = self.redact(record.msg)
        if isinstance(record.args, dict):
            for k in record.args.keys():
                record.args[k] = self.redact(record.args[k])
        else:
            record.args = tuple(self.redact(arg) for arg in record.args)
        return True

    def redact(self, msg):
        msg = isinstance(msg, basestring) and msg or str(msg)
        for pattern in self._patterns:
               msg = msg.replace(pattern, "<<TOP SECRET!>>")
        return msg

{% endhighlight %}

1. Notice how the `RedactingFilter` class inherits from `logging.Filter`
1. As you can see, our initializer expects a `patterns` argument
1. Our second method `filter` is called automatically by the framework. This corresponds with the last diamond in this [flowchart](https://docs.python.org/2/howto/logging.html#logging-flow). If this method returns True, the log is written. Otherwise it is rejected. In our case, it always approves all log entries.
1. Notice how our `filter` method expects a `record` argument. This is always a `LogRecord` instance which we can manipulate according to our needs. In our case, we take the log's `msg` and replace all occurances of the patterns we declared in the config file with "<<TOP SECRET!>>". You'll notice that it's just a small step from here to regular expressions. I'll let you experiment with that on your own. :-)

Finally, let's attach this filter to our handler:

{% highlight yaml linenos %}
handlers:
    file:
        class: logging.handlers.RotatingFileHandler
        formatter: simple
        filename: /var/log/myapp/myapp.log
        filters:
            - myfilter
{% endhighlight %}

Notice how `filters` is an array. Therefore we can add as many filters as we need here.

## Redacting logs using a Custom Formatter

In this approach, we will use a custom formatter objects that simply wrap the real formatter objects such that, messages can be intercepted right after they have been formatted but before the `handler` gets a chance to write them. This has the advantage that it is very simple, but unlike the previous approach, it can only be configured programmatically (which is actually good in a way, as it will always get applied irrespective of what the user configures).

First we will create a formatter class which is just a wrapper that simply *proxies* all the original formatter attributes, except for the `format()` method.  Let’s assume we have a formatters.py file with the following contents:

{% highlight python linenos %}

class RedactingFormatter(object):
    def __init__(self, orig_formatter, patterns):
        self.orig_formatter = orig_formatter
        self._patterns = patterns

    def format(self, record):
        msg = self.orig_formatter.format(record)
        for pattern in self._patterns:
            msg = msg.replace(pattern, "***")
        return msg

    def __getattr__(self, attr):
        return getattr(self.orig_formatter, attr)

{% endhighlight %}

In the code right after `logging` is configured ([see](#configuring-your-loggers)), we need to add the below code to wrap all formatters (*a word of caution*: the below code assumes that all the handlers are on the root logger, but this may not always be the case):

{% highlight python linenos %}
for h in logging.root.handlers:
    h.setFormatter(FilterFormatter(h.formatter))
{% endhighlight %}


## Additional Reading

There's more to the logging framework than what I've discussed here. So go ahead and read
some more from the [official docs](https://docs.python.org/2/library/logging.html).
