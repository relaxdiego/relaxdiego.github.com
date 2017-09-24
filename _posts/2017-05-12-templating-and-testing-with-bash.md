---
layout: post
title: Templating and Testing With Bash
comments: true
categories: bash, shell, scripting, templating, tdd, bdd, rspec
---

I needed to write a simple templating system in Bash and wanted to do
it with TDD helping me along the way. Here's what I came up with.


## Prior Art

I'm not the first person to do this. I drew my inspiration from the following:

* [http://code.haleby.se/2015/11/20/simple-templating-engine-in-bash/](http://code.haleby.se/2015/11/20/simple-templating-engine-in-bash/)
* [http://blog.lavoie.sl/2012/11/simple-templating-system-using-bash.html](http://blog.lavoie.sl/2012/11/simple-templating-system-using-bash.html)


## My Requirements

I wanted to be able to write a template script that contained placeholder values
to be interpolated by my bash templating system as well as regular variables
that should be left untouched. For example:

{% assign template_ph = '{{docker_storage_path}}' %}
{%highlight sh linenos%}
#!/usr/bin/env bash
device_path={{template_ph}}
message="Formatting $device_path"

echo "$message"
wipefs -f $device_path
mkfs.ext4 -F $device_path
{%endhighlight%}

Could be rendered via:

{%highlight sh %}
$ docker_storage_path=/dev/sdb ./render my-template > my-script.sh
{%endhighlight%}

And the output would be a file named `my-script.sh` with the following contents:

{%highlight sh linenos%}
#!/usr/bin/env bash
device_path=/dev/sdb
message="Formatting $device_path"

echo "$message"
wipefs -f $device_path
mkfs.ext4 -F $device_path
{%endhighlight%}

That is, only `{{template_ph}}` would be interpolated but not `$device_path`
and `$message`. This ruled out simple solutions using just `echo`.


## TDD Requirements

I also wanted to write my rendering system with TDD first and foremost and
I wanted to write my tests this way:

{%highlight sh linenos%}
it "renders the template as expected" "test_variable=MYVALUE" <<EOF
somerandomtextMYVALUEmorerandomtext
\$symbol_that_doesnt_get_rendered
EOF
{%endhighlight%}

That is, I wanted a testing DSL similar to RSpec where I provide the test
name as the first arg, the variable declaration as the second arg, and the
expected output as the 3rd arg in the form of a HEREDOC.

And just as important, I want this TDD framework and test as a single file
with no external dependencies.

![Take the red pill](/assets/images/morpheus-tdd.jpg)
<center>Generated via https://memegenerator.net</center>

## The TDD "Framework"

Turns out, it was not at all hard to implement it. Here's the good bits

{%highlight sh linenos%}
failures=false
parent_dir=$( cd "$( dirname "${BASH_SOURCE[0]}"  )" && pwd  )
render=$parent_dir/render
template=$parent_dir/test-template

it() {
    cmd="$2 $(basename $render) $(basename $template)"
    expected=

    while IFS= read -r line; do expected+="$line"$'\n'; done;

    expected=${expected%$'\n'}
    if received=$(eval "$2 $render $template" 2>&1); then
        foo=bar # noop
    fi

    if [[ "$received" == "$expected" ]]; then
        echo -e "\e[32mPASSED:\e[39m it $1"
        echo "        $cmd"
    else
        echo -e "\e[31mFAILED:\e[39m it $1"
        echo "        $cmd"
        echo
        echo "============= expected ============="
        printf '%s\n' "$expected"
        echo "============= received ============="
        printf '%s\n' "$received"
        echo "===================================="
        failures=true
    fi

    echo ""
}
{%endhighlight%}

Now I could write my tests as follows:

{%highlight sh linenos%}
test_value=$(uuidgen)

it "renders the template as expected" "test_variable=$test_value" <<EOF
somerandomtext${test_value}morerandomtext
\$symbol_that_doesnt_get_rendered
EOF


it "throws an error if test_variable is undefined" "someother_var=someother_value" <<EOF
ERROR: test_variable is not defined
EOF


it "doesn't throw an error if test_variable is defined but empty" "test_variable=" <<EOF
somerandomtextmorerandomtext
\$symbol_that_doesnt_get_rendered
EOF


test_value='http://'$(uuidgen)'/some/path'

it "works with values that have forward slashes" "test_variable=$test_value" <<EOF
somerandomtext${test_value}morerandomtext
\$symbol_that_doesnt_get_rendered
EOF
{%endhighlight%}


When executing, the test outputs PASSES and FAILURES like so:


{% highlight text %}
PASSED: it throws an error if test_variable is undefined
        someother_var=someother_value render test-template

FAILED: it doesn't throw an error if test_variable is defined but empty
        test_variable= render test-template

============= expected =============
somerandomtextmorerandomtext
$symbol_that_doesnt_get_rendered
============= received =============
ERROR: test_variable is not defined
====================================
{% endhighlight %}


## The Templating Code

First, we take all the variable names used in the template and put them in
a variable.

{% highlight sh %}
varnames=$(grep -oE '\{\{([A-Za-z0-9_]+)\}\}' $1 | 
           sed -rn 's/.*\{\{([A-Za-z0-9_]+)\}\}.*/\1/p' | 
           sort | 
           uniq)
{% endhighlight %}

Next, we'd iterate through each varname to check if they're defined. However,
we have to be aware that we'll need to do some meta-programming or reflection
here because when we iterate through each item of varnames, what we're getting
is a string that contains the name of the variable whose value we want to get.
In other words, the following will not work:


{% highlight sh linenos %}
for varname in $varnames; do
        # Check if the variable named $varname is defined
        if [ -z ${varname} ]; then
                echo "ERROR: $varname is not defined" >&2
                error=true
        fi
done
{% endhighlight %}

because in line 3, `${varname}` will always evaluate to a string such as `"variable_one"`
instead of the actual `variable_one` which means the `[ -z` test will always be false.
To get to the actual variable, we take advantage of Bash's built in indirect expansion:


{% highlight sh linenos %}
for varname in $varnames; do
        # Check if the variable named $varname is defined
        if [ -z ${!varname} ]; then
                echo "ERROR: $varname is not defined" >&2
                error=true
        fi
done
{% endhighlight %}

By prepending a `!` to `varname`, Bash will understand that you want to get the
value of the variable whose name is equal to `varname`. That's right, Bash knows
metaprogramming!

Once you're done jumping up and down with delight, you'll need to sit back down
and realize that we're not quite done yet because in one of the tests above, we
should allow for a variable to be defined but empty. In our code above, however,
should `${!varname}` return an empty string, `[ -z` will consider that undefined!

Luckily, Bash comes with yet another trick which is:

{% highlight sh linenos %}
for varname in $varnames; do
        # Check if the variable named $varname is defined
        if [ -z ${!varname+x} ]; then
                echo "ERROR: $varname is not defined" >&2
                error=true
        fi
done
{% endhighlight %}

So, again, in line 3, all we did was add `+x` and what Bash will do is that if
`${!varname}` is defined but empty, the string `x` will be appended to the empty
value, returning `x`. However, if `${!varname}` expanded to an undefined
variable, Bash immediately stops expansion and won't even append `x` (because
there is nothing to append to!) which means that nothing will be returned.

And so there you have it. A very simple Bash templating solution written in
less than 20 effective lines of code and fully tested by a test framework written
in less than 50 effective lines of code. Not bad for old timer Bash!

## The Code

Check it out in my [GitHub account](https://github.com/relaxdiego/renderest)!
