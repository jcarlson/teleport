FROM ruby:3.0.2

# Install system dependencies for packet capture
RUN apt-get update && \
    apt-get install -y libpcap-dev ruby-build iptables net-tools

# For development, we can debug in a docker container, which is nice
# For production, we would exclude these dependencies using multi-stage Dockerfiles or similar
RUN gem install debase ruby-debug-ide

WORKDIR /opt/tac

# Copy the dependency lock files and install dependencies
COPY    Gemfile Gemfile.lock tac.gemspec ./
COPY    lib/tac/version.rb ./lib/tac/version.rb
# In production, we would trim some fat here by skipping test or dev dependencies
RUN     bundle install

# Copy the rest of the app into Docker
# In production, we would want to include a .dockerignore file to trim fat and reduce attack surface
COPY . .

# Build the gem and install it to the local system
RUN rake build && rake install

# Set the entrypoint and command to run
ENTRYPOINT  ["tac"]
CMD         ["start"]
