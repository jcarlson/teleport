# Question and Answers

## Level 1

### 1. How would you prove the code is correct?

I've used a combination of unit testing and human testing on this solution. 
There are probably edge cases I haven't thought of, but the great thing is, if I find
any, I have a nice test suite to add cases to so mistakes are not made twice!

For human testing here, I used `netcat` primarily, e.g.:

```bash
$ for port in 8080 8081 8082 8083 8084; do nc -w2 -z {{target-host}} $port; done
```

### 2. How would you make this solution better?

Assuming we're talking about the `/proc/net/tcp` version of this app, I would do away
with polling, since it's likely to miss connections.

Beyond that, for high-volume systems, Ruby is probably not the _most_ performant runtime
for this sort of application. I might use C or C++; something that compiles down to
assembly closer to the metal.

### 3. Is it possible for this program to miss a connection?

Yes, since we are only polling every 10s, a connection can appear and disappear within 
a relatively short time nad therefore not appear on this list. Specifically, `/proc/net/tcp`
is unlikely to be very helpful for detecting port scans, since the scanner doesn't typically
stay connected on any port.

### 4. If you weren't following these requirements, how would you solve the problem of logging every new connection?

Generally speaking I try not to re-invent wheels. There are plenty of off-the-shelf appliances
and network security devices on the market that offer this type of functionality, so unless
making this type of software was actually my core line of business, I would probably look at buying
a product off-the-shelf.

## Level 2

### 1. Why did you choose `x` to write the build automation?

Ruby all but includes Rake out of the box. It's a pretty established community best practice.
In fact, for building a Gem (which I've done here), many of the build steps I needed are
provided out of the box, so I didn't have to do anything at all except include Rake in my project.

"Convention over Configuration" is the theme for Ruby (and especially Rails).

### 2. Is there anything else you would test if you had more time?

I started looking at a tool called Aruba, which helps to test command line APIs. This broke
down a little since I can't effectively run this application on my Mac in my comfortable dev
environment. I would have needed to spend more time getting CI setup on a Linux machine.

### 3. What is the most important tool, script, or technique you have for solving problems in production? Explain why this tool/script/technique is the most important.

In local development, my goto tool of choice is the debugger. Stepping through code with a good debugger
is so much faster than logging endless statements to `STDOUT`.

I've been tinkering with remote debugging, especially in Docker. It's pretty neat to be able to debug live
code on a remote system.

In production, though, since you would not want to step-debug live customer-facing processes, the best tool
is probably an APM tool like New Relic APM (or Datadog Agent, or AWS CloudWatch Agent, or...). You get a lot
of metrics out of these systems and stack traces when things go wrong without placing human analysis in the
execution path.

## Level 3

### 1. If you had to deploy this program to hundreds of servers, what would be your preferred method? Why?

Depends on the platform I'm deploying to. In AWS, it might be feasible to install this tool with a few lines
of script in the EC2 instance's user data script.

Capistrano is the Ruby tooling of choice, which lets you run commands on many servers at once, but it's not 
as deterministic as tools like Terraform or Ansible, which are probably a better choice for larger deployments.

Baking an AMI is always option, too, if you're into that sort of thing in AWS...

### 2. What is the hardest technical problem or outage you've had to solve in your career? Explain what made it so difficult?

Some of the hardest problems I've had to triage in the last couple years have involved parts of AWS infrastructure,
like load balancers, that are effectively black boxes. You don't really get to peek behind the curtains in those components.

We had an issue about a year ago where an application was performing poorly under load. We knew the application wasn't as
performant as it could be, so we added server capacity temporarily to compensate.

Despite the added capacity, the application continued to struggle. We looked at tuning app performance and database queries
that were falsely reported as problematic by New Relic APM.

Ultimately, we discovered that despite having plenty of capacity, the load balancer was sending a disproportionate amount
of traffic to one server, which then became bogged down even further.

Diagnosing this was difficult since AWS customers don't have any inside access to the load balancer appliances to inspect them.

After speaking with AWS Support, the informed us of a relatively new feature to change the load balancer routing algorithm to
"Least Outstanding Requests", which seemed to help solve our situation.
