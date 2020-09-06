FROM ubuntu:18.04

# Prerequisites
### Android SDK Flutter OpenJDK
RUN apt-get -qq update && apt-get -qq install -y curl git unzip \
                                             xz-utils zip libglu1-mesa \
                                             openjdk-8-jdk wget language-pack-en

### ruby bundle (for fastlane)
ENV LANG en_US.UTF-8 
ENV LANGUAGE en_US:en 
ENV LC_ALL en_US.UTF-8
RUN apt-get -qq install -y git curl libssl-dev libreadline-dev \
                           zlib1g-dev autoconf bison build-essential \
                           libyaml-dev libreadline-dev libncurses5-dev \
                           libffi-dev libgdbm-dev gnupg2

# Set up new user
RUN useradd -ms /bin/bash developer
USER developer
WORKDIR /home/developer

#### ruby
RUN curl -sSL https://rvm.io/pkuczynski.asc | gpg2 --import -
RUN curl -L https://get.rvm.io | bash -s stable
CMD source /home/developer/.profile 
CMD source /home/developer/.rvm/scripts/rvm
ENV PATH "$PATH:/home/developer/.rvm/bin" 
RUN rvm autolibs disable
RUN rvm install ruby-2.7.0
RUN rvm reload
RUN ["/bin/bash", "-l", "-c", "rvm use 2.7.0 --default" ]

#### bundle
RUN ["/bin/bash", "-l", "-c", "rvm requirements; gem install bundler --no-document"]
RUN ["/bin/bash", "-l", "-c", "gem list"]

##### PATH : ruby gem bundle 
ENV PATH "$PATH:/home/developer/.rvm/rubies/ruby-2.7.0/bin"
RUN ruby --version
RUN gem --version
RUN bundle --version

#### Prepare Android directories and system variables
RUN mkdir -p Android/sdk
ENV ANDROID_SDK_ROOT /home/developer/Android/sdk
RUN mkdir -p .android && touch .android/repositories.cfg
   
# Set up Android SDK
RUN wget -q -O sdk-tools.zip https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip
RUN unzip -qq sdk-tools.zip && rm sdk-tools.zip
RUN mv tools Android/sdk/tools
RUN cd Android/sdk/tools/bin && yes | ./sdkmanager --licenses
RUN cd Android/sdk/tools/bin && ./sdkmanager "build-tools;29.0.2" \
                                             "patcher;v4" "platform-tools" \
                                             "platforms;android-29" \
                                             "sources;android-29" >/dev/null
ENV PATH "$PATH:/home/developer/Android/sdk/platform-tools"

# Download Flutter SDK
RUN git clone https://github.com/flutter/flutter.git
ENV PATH "$PATH:/home/developer/flutter/bin"
   
# Run basic check to download Dark SDK
RUN flutter doctor
