FROM ruby:2.6-stretch

ENV DEBIAN_FRONTEND=noninteractive

# some of ruby's build scripts are written in ruby
# we purge this later to make sure our final image uses what we just built
RUN echo "export phantomjs=/usr/bin/phantomjs" > .bashrc

RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN apt-get update && \
    apt-get install -y build-essential nodejs libfreetype6 libfontconfig1 libnss3-dev libgconf-2-4 && \
    apt-get install -y npm imagemagick && \
    apt-get autoremove -y && \
    apt-get clean all

RUN set -xe \
    && apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl socat \
    && apt-get install -y --no-install-recommends xvfb x11vnc fluxbox xterm \
    && apt-get install -y --no-install-recommends sudo \
    && apt-get install -y --no-install-recommends supervisor \
    && rm -rf /var/lib/apt/lists/*

RUN set -xe \
    && curl -fsSL https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update \
    && apt-cache showpkg google-chrome-stable \
    && apt-get install -y google-chrome-stable=77.0.3865.90-1 \
    && rm -rf /var/lib/apt/lists/*


RUN npm config set user 0 && npm config set unsafe-perm true
RUN npm install npm
RUN npm install -g phantomjs-prebuilt@2.1.16 casperjs@1.1.4
RUN gem install aws-sdk

# Make sure decent fonts are installed. Thanks to http://www.dailylinuxnews.com/blog/2014/09/things-to-do-after-installing-debian-jessie/
RUN echo "deb http://ftp.us.debian.org/debian jessie main contrib non-free" | tee -a /etc/apt/sources.list
RUN echo "deb http://security.debian.org/ jessie/updates contrib non-free" | tee -a /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y ttf-freefont ttf-mscorefonts-installer ttf-bitstream-vera ttf-dejavu ttf-liberation && \
   apt-get autoremove -y && \
   apt-get clean all


#Install Wraith
RUN mkdir /app
COPY . /app
WORKDIR /app

RUN bundle install --system
RUN gem build -V wraith
RUN gem install wraith

RUN chromedriver-update 77.0.3865.40
RUN chromedriver -version

# Test step, to check it's installed correctly
RUN wraith
RUN google-chrome -version
RUN chromedriver -version
ENTRYPOINT [ "wraith" ]
