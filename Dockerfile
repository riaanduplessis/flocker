FROM ubuntu:18.04
LABEL Description="This image sets up the android and flutter SDK" Vendor="riaanduplessis" Version="latest"

# Prerequisites
RUN apt update && apt install -y curl git unzip xz-utils zip libglu1-mesa openjdk-8-jdk wget

# Set up new user
RUN useradd -ms /bin/bash developer
USER developer
WORKDIR /home/developer
   
# Prepare Android directories and system variables
RUN mkdir -p Android/sdk
ENV ANDROID_SDK_ROOT /home/developer/Android/sdk
RUN mkdir -p .android && touch .android/repositories.cfg

ARG build_tools_ver
ENV build_tools_ver=${build_tools_ver:-29.0.2}

ARG patcher_ver
ENV patcher_ver=${patcher_ver:-v4}

ARG platforms
ENV platforms=${platforms:-"android-29"}

ARG sources
ENV sources=${sources:-"android-29"}

# Set up Android SDK
RUN wget -O sdk-tools.zip https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip
RUN unzip sdk-tools.zip && rm sdk-tools.zip
RUN mv tools Android/sdk/tools
RUN cd Android/sdk/tools/bin && yes | ./sdkmanager --licenses
RUN cd Android/sdk/tools/bin && ./sdkmanager "build-tools;$build_tools_ver" "patcher;$patcher_ver" "platform-tools" "platforms;$platforms" "sources;$sources"
ENV PATH "$PATH:/home/developer/Android/sdk/platform-tools"

# Download Flutter SDK
RUN git clone https://github.com/flutter/flutter.git -b stable --depth 1
ENV PATH "$PATH:/home/developer/flutter/bin"
   
# Run basic check to download Dark SDK
RUN flutter doctor