# Teleport Automation Challenge (tac)

This project implements the Level 4 Automation Challenge for Teleport.

See the [challenge](CHALLENGE.md).

Also please see my [answers to each level's questions](Q_AND_A.md).

## Prerequisites

Local installation and development of this project requires the following frameworks or dependencies to be installed on your system:

- A Linux operating system
  - This solution does not work, and has not been tested, on other operating systems
- Ruby 3.0.2 (Ruby 2.4+ will probably work too, but I did not test with older versions)
  - I recommend using [rbenv](https://github.com/rbenv/rbenv) to install Ruby if your system does not have an adequate version
  - You may also need to install `ruby-build`
- Bundler
  - Ruby installations don't always include the `bundler` gem; `gem install bundler` if you don't have it
- `libpcap`, `libpcap-dev`
  - Package names may vary by Linux distribution; on Ubuntu 20.04 it is `libpcap0.8` and `libpcap0.8-dev`
- `iptables`
  - For managing the network firewall rules
- Docker (any recent version should do nicely, tested on 20.10.7)

## Installation

Start by cloning this repository:

```bash
$ git clone git@github.com:jcarlson/teleport.git jc-tac
$ cd jc-tac
```

Install gem dependencies with Bundler; you can run `bundle install` or just run `bin/setup`

```bash
$ bundle install
```

## Running tests

You can run the test suite with Rake. The default Rake task will run RSpec, Cucumber and Rubocop.

```bash
$ rake

# Or just unit tests
$ rake spec

# Or just features
$ rake cucumber

# Or just Rubocop
$ rake rubocop
```

## Running the application

Packet capture with Ruby's `pcaprub` Gem requires `root` permissions. 

You can run the application from the source directory with:

```bash
$ bundle exec exe/tac <command>

# try `help`
$ bundle exec exe/tac help

# start the packet capture and mitigation process
$ [sudo] bundle exec exe/tac start
```

## Installing the application

You can install the application binaries to your local system with:

```bash
$ rake install
```

This will build the Gem and install it to your Ruby Gems installation directory,
which should make the `tac` executable available system-wide.

Once installed, you can run:

```bash
$ tac start
```

### Note

I was about 2/3 of the way through this challenge before I realized that some Linux distributions
include a built-in called `tac`, which is like `cat` but reads in reverse order.

If you install this gem to your system, make sure your Ruby Gems paths come before any
other paths.

## Docker and Docker Compose

A Dockerfile is provided, to make installation and execution simpler. Running the app
in Docker requires a privileged runtime, and to inspect and manage the host's network
devices, it will need to use the `host` network.

Rake tasks are provided to help with this process:

```bash
$ rake docker:build

# equivalent to:
$ docker build -t jcarlson/teleport .

$ rake docker:run

# equivalent to:
$ docker build -t jcarlson/teleport . && \
  docker run --privileged --network host -it jcarlson/teleport
```

### Docker Compose

Docker Compose is also an option. Simply run `docker-compose up` to start the application.

## Prometheus Metrics

Prometheus metrics are provided on the host's port 8080:

[http://<your-server-hostname-or-ip>:8080/metrics](http://localhost:8080/metrics)

You can customize the port as follows `tac start --port 5000`. 
