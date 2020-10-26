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

ARG BUILD_TOOLS_VER
ENV BUILD_TOOLS_VER=${BUILD_TOOLS_VER:-29.0.2}

ARG PATCHER_VER
ENV PATCHER_VER=${PATCHER_VER:-v4}

ARG PLATFORMS
ENV PLATFORMS=${PLATFORMS:-"android-29"}

ARG SOURCES
ENV SOURCES=${SOURCES:-"android-29"}

# Set up Android SDK
RUN wget -O sdk-tools.zip https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip
RUN unzip sdk-tools.zip && rm sdk-tools.zip
RUN mv tools Android/sdk/tools
RUN cd Android/sdk/tools/bin && yes | ./sdkmanager --licenses
RUN cd Android/sdk/tools/bin && ./sdkmanager "build-tools;$BUILD_TOOLS_VER" "patcher;$PATCHER_VER" "platform-tools" "platforms;$PLATFORMS" "sources;$SOURCES"
ENV PATH "$PATH:/home/developer/Android/sdk/platform-tools"

# Download Flutter SDK
RUN git clone https://github.com/flutter/flutter.git -b stable --depth 1
ENV PATH "$PATH:/home/developer/flutter/bin"
   
# Run basic check to download Dark SDK
RUN flutter doctor