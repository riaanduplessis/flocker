# syntax=docker/dockerfile:1.3

# Copyright (c) 2022 Riaan du Plessis. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# ╔═════════════════════════════════════════════════╗
# ║ Docker stage handling required tool downloads   ║
# ╚═════════════════════════════════════════════════╝
FROM debian:11-slim as downloads

# Install required packages to fetch installation files
RUN apt-get update \
    && apt-get -y --no-install-recommends install \
            git \
            wget \
            unzip \
            ca-certificates \
    # Clean up
    && apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

# Set the URL where the Android command line tools will be downloaded from
ARG ANDROID_TOOLS_URL="https://dl.google.com/android/repository/commandlinetools-linux-8092744_latest.zip"

# Download the Android command line tools and set up the directory structure correct
RUN mkdir -p "/tools/android/cmdline-tools" && \
    wget --random-wait "${ANDROID_TOOLS_URL}" -O "/tools/android/cmdline-tools/commandline-tools.zip" && \
	unzip "/tools/android/cmdline-tools/commandline-tools.zip" -d "/tools/android/cmdline-tools" && \
    rm "/tools/android/cmdline-tools/commandline-tools.zip" && \
    mv "/tools/android/cmdline-tools/cmdline-tools" "/tools/android/cmdline-tools/latest"

# Get the latest stable Flutter from GitHub
RUN git clone https://github.com/flutter/flutter.git "/tools/flutter" -b stable --depth 1

# ╔════════════════════════════════════════════════════════════════════════════════════════════════════╗
# ║ Final stage that will install Android and Flutter using the tools downloaded in the previous stage ║
# ╚════════════════════════════════════════════════════════════════════════════════════════════════════╝
FROM debian:11-slim as Flocker

LABEL dev.riaanduplessis.name="Flocker"
LABEL dev.riaanduplessis.description="Docker image for Flutter development"

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update \
    && apt-get -y --no-install-recommends install \
            lib32stdc++6 \
            libglu1-mesa \
            default-jdk-headless \
            git \
            curl \
            unzip \
            liblzma-dev \
            # Packages below are required for Linux desktop support
            clang \
            cmake \
            ninja-build \
            pkg-config \
            libgtk-3-dev \
    # Clean up
    && apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

# Set the primary android & flutter root directories & also the deprecated $ANDROID_SDK_ROOT
ENV ANDROID_HOME="/opt/android"
ENV FLUTTER_HOME="/opt/flutter"
ENV ANDROID_SDK_ROOT="${ANDROID_HOME}"

# Add the tools to the system path
ENV PATH="${ANDROID_HOME}/cmdline-tools/latest/bin:${PATH}"
ENV PATH="${ANDROID_HOME}/platform-tools:${PATH}"
ENV PATH="${ANDROID_HOME}/tools:${PATH}"
ENV PATH="${FLUTTER_HOME}/bin:${PATH}"

# Create a group and user named 'flocker'
RUN groupadd -r flocker && useradd -r -g flocker flocker && mkdir /home/flocker && chown -R flocker:flocker /home/flocker
USER flocker

# Copy the downloaded files from previous stage
COPY --chown=flocker:flocker --from=downloads /tools /opt

# Use build args to set the installation versions
ARG BUILD_TOOLS_VER=32.0.0
ARG PLATFORM_VER=32

# Install Android tools using the SDK Manager
RUN yes "y" | sdkmanager --verbose \
    "platform-tools" \
    "build-tools;${BUILD_TOOLS_VER}" \
    "platforms;android-${PLATFORM_VER}"

# Disable Flutter analytics and crash reporting on the builder
# and enable support for Linux desktop development
RUN flutter config --no-analytics --enable-linux-desktop

# Perform a Flutter artifact precache so that no extra assets
# need to be downloaded on demand
RUN flutter precache

# Enable the Flutter development tools
RUN flutter pub global activate devtools

# Accept licenses
RUN yes "y" | flutter doctor --android-licenses

# Perform a doctor run
RUN flutter doctor -v

ENTRYPOINT [ "/bin/bash" ]
