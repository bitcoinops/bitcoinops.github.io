# Use an official Ruby runtime as a parent image
FROM ruby:2.6.4

# Set the working directory in the container
WORKDIR /usr/src/app

# Clone the bitcoinops.github.io repository
RUN git clone https://github.com/bitcoinops/bitcoinops.github.io.git

# Change to the repository directory
WORKDIR /usr/src/app/bitcoinops.github.io

# Install program to configure locales
RUN apt-get update
RUN apt-get install -y locales
RUN dpkg-reconfigure locales && \
  locale-gen C.UTF-8 && \
  /usr/sbin/update-locale LANG=C.UTF-8

# Install needed default locale for Makefly
RUN echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen && \
  locale-gen

# Set default locale for the environment
ENV LC_ALL C.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

# Install any needed gems specified in Gemfile
RUN bundle install

# Make port 4000 available to the world outside this container
EXPOSE 4000
