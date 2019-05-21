FROM ruby:2.6-stretch

# some of ruby's build scripts are written in ruby
# we purge this later to make sure our final image uses what we just built
RUN echo "export phantomjs=/usr/bin/phantomjs" > .bashrc
#RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 9D6D8F6BC857C906
#RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 7638D0442B90D010
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN apt-get update && \
    apt-get install -y build-essential nodejs libfreetype6 libfontconfig1 libnss3-dev libgconf-2-4 && \
    apt-get install -y chromedriver npm imagemagick && \
    apt-get autoremove -y && \
    apt-get clean all
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
RUN apt install -y ./google-chrome-stable_current_amd64.deb
RUN rm ./google-chrome-stable_current_amd64.deb
RUN npm config set user 0 && npm config set unsafe-perm true
RUN npm install npm
RUN npm install -g phantomjs-prebuilt@2.1.16 casperjs@1.1.4
RUN gem install wraith
RUN gem install aws-sdk

# Make sure decent fonts are installed. Thanks to http://www.dailylinuxnews.com/blog/2014/09/things-to-do-after-installing-debian-jessie/
RUN echo "deb http://ftp.us.debian.org/debian jessie main contrib non-free" | tee -a /etc/apt/sources.list
RUN echo "deb http://security.debian.org/ jessie/updates contrib non-free" | tee -a /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y ttf-freefont ttf-mscorefonts-installer ttf-bitstream-vera ttf-dejavu ttf-liberation

ENTRYPOINT [ "wraith" ]
