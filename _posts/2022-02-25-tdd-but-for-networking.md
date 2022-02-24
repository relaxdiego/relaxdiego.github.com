---
layout: post
title: TDD but for Networking
comments: false
categories: aws, vpc, networking, tdd
social_preview_suffix: -tdd-networking
---

Tired of spending precious time trying to debug why one AWS resource
can't talk to another? Add [VPC Reachability Analyzer](https://docs.aws.amazon.com/vpc/latest/reachability/what-is-reachability-analyzer.html)
to your toolkit, mix it up with some Test-Driven Development (TDD)
workflow and take back some of your sanity!

## ~~Write the Test~~ Create the Path, Watch it Fail...

Create the path to analyze before your networking config is fully configured
then see helpful error messages like the following:

{% highlight json linenos %}
{
  "destination": {
    "arn": "arn:aws:ec2:xx-xxxx-x:xxxxxxxx:vpc-peering-connection/pcx-xxxxxxxxx",
    "id": "pcx-xxxxxxx"
  },
  "explanationCode": "NO_ROUTE_TO_DESTINATION",
  "routeTable": {
    "arn": "arn:aws:ec2:xx-xxxx-x:xxxxxxxx:route-table/rtb-xxxxxxxxxxx",
    "id": "rtb-xxxxxxxxxxxxxx"
  },
  "vpc": {
    "arn": "arn:aws:ec2:xx-xxxx-x:xxxxxxxx:vpc/vpc-xxxxxxxxxxxx",
    "id": "vpc-xxxxxxxxxxxxxx"
  }
}
{% endhighlight %}

## ~~Write the Code~~ Configure the Network, Watch it Pass...

Once you've fixed the errors above and re-run the analysis, you'll get
the following report:

![All is well](/assets/images/tdd-networking/analyzer-report-good.png)

From here, you can "refactor" your networking config to make it more
restrictive as needed. With every change, you can re-run the analysis
(NOTE: $0.10/run) to ensure it hasn't regressed. If this TDD workflow
sounds like it could be useful to you, read on!

## A Tale of Two Resources

We'll start by defining two resources that need to talk to each
other. Let's say we want two instances in two different subnets
to talk to each other.

_CloudFormation, I know. At the time of writing this article,
[Terraform didn't yet support Reachability Analyzer resources](https://github.com/hashicorp/terraform-provider-aws/issues/16715) so I had to
use CF._

{% highlight yaml linenos %}
{% include code-snippets/tdd-networking/s01_first_pass.yml %}
{% endhighlight %}

Let's create the stack:

{% highlight bash linenos %}
export AWS_REGION=your-preferred-region
export STAGE=dev

export INSTANCE1_VPC_ID=your-vpc-id
export INSTANCE1_AMI_ID=your-ami-id
export INSTANCE1_KEY_NAME=your-key-name
export INSTANCE1_SUBNET_ID=your-subnet-id

export INSTANCE2_VPC_ID=your-vpc-id
export INSTANCE2_AMI_ID=your-ami-id
export INSTANCE2_KEY_NAME=your-key-name
export INSTANCE2_SUBNET_ID=your-subnet-id

aws cloudformation create-stack --stack-name DeceptivelySimpleProject \
    --template-body file://_includes/code-snippets/tdd-networking/s01_first_pass.yml \
    --parameters \
        ParameterKey=Stage,ParameterValue=$STAGE \
        ParameterKey=Instance1VpcId,ParameterValue=$INSTANCE1_VPC_ID \
        ParameterKey=Instance1AmiId,ParameterValue=$INSTANCE1_AMI_ID \
        ParameterKey=Instance1KeyName,ParameterValue=$INSTANCE1_KEY_NAME \
        ParameterKey=Instance1SubnetId,ParameterValue=$INSTANCE1_SUBNET_ID \
        ParameterKey=Instance2VpcId,ParameterValue=$INSTANCE2_VPC_ID \
        ParameterKey=Instance2AmiId,ParameterValue=$INSTANCE2_AMI_ID \
        ParameterKey=Instance2KeyName,ParameterValue=$INSTANCE2_KEY_NAME \
        ParameterKey=Instance2SubnetId,ParameterValue=$INSTANCE2_SUBNET_ID
{% endhighlight %}

Head on over to the CloudFormation console to see the progress:

![Stack Events](/assets/images/tdd-networking/stack-events.png)

Next, go to the VPC console and to the Reachability Analyzer view:

![Menu](/assets/images/tdd-networking/menu.png)

Then hit the Analyze Path button

![Analyze Path](/assets/images/tdd-networking/analyze.png)

You're going to need to hit refresh for the new analysis to show up.

![Refresh](/assets/images/tdd-networking/refresh.png)

Keep hitting that refresh button until the status is no longer Pending.

![](/assets/images/tdd-networking/analysis-01-done.png)

When you expand that Details section, you'll get a more detailed explanation
of why the instance can't reach the other.

![](/assets/images/tdd-networking/analysis-02-error.png)

## Fix the Security Group

So let's fix Instance2's security group so that it allows traffic from
Instance1's security group:

{% highlight yaml linenos %}
{% include code-snippets/tdd-networking/s02_fix_sg.yml %}
{% endhighlight %}

Take note of lines 60 to 63 where we add an ingress rule allowing incoming
traffic from Instance1's security group.

## Watch it Pass!

{% highlight bash linenos %}
aws cloudformation update-stack --stack-name DeceptivelySimpleProject \
    --template-body file://_includes/code-snippets/tdd-networking/s02_fix_sg.yml \
    --parameters \
        ParameterKey=Stage,ParameterValue=$STAGE \
        ParameterKey=Instance1VpcId,ParameterValue=$INSTANCE1_VPC_ID \
        ParameterKey=Instance1AmiId,ParameterValue=$INSTANCE1_AMI_ID \
        ParameterKey=Instance1KeyName,ParameterValue=$INSTANCE1_KEY_NAME \
        ParameterKey=Instance1SubnetId,ParameterValue=$INSTANCE1_SUBNET_ID \
        ParameterKey=Instance2VpcId,ParameterValue=$INSTANCE2_VPC_ID \
        ParameterKey=Instance2AmiId,ParameterValue=$INSTANCE2_AMI_ID \
        ParameterKey=Instance2KeyName,ParameterValue=$INSTANCE2_KEY_NAME \
        ParameterKey=Instance2SubnetId,ParameterValue=$INSTANCE2_SUBNET_ID
{% endhighlight %}
After you update the stack and analyze the path again, you should see another
analysis in the Analysis section, this time showing that the connection is
reachable:

![](/assets/images/tdd-networking/analysis-03-pass.png)

And if you look at the details further down the page, you'll get a listing
of all the various resources in the path.

![](/assets/images/tdd-networking/analysis-04-details.png)

At this point, you're basically done but it would also be prudent to see
which parts of this path can be adjusted to make it more secure. The process
will be pretty much the same: make minor adjustments, re-run the analysis,
see it fail, make more adjustments. The number of iterations you take will
depend on your budget because each analysis will cost you $0.10 as per
[Amazon's pricing page](https://aws.amazon.com/vpc/pricing/). I'll leave that
exercise up to you.

Experiment with the above stack by changing the VPC and subnet of the instances
then use the Reachability Analyzer to guide you in configuring your network
properly. Happy hunting!
