# Copyright (c) 2021 Riaan du Plessis. All Rights Reserved.
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

# syntax=docker/dockerfile:1.3
FROM debian:stretch

LABEL dev.riaanduplessis.name="Flocker"
LABEL dev.riaanduplessis.description="Docker image for Flutter development"

# Install Dependencies
RUN apt update && apt install -y \
  git \
  wget \
  curl \
  unzip \
  lib32stdc++6 \
  libglu1-mesa \
  default-jdk-headless

# Set the URL where the tools will be downloaded from
ENV ANDROID_TOOLS_URL="https://dl.google.com/android/repository/commandlinetools-linux-7583922_latest.zip"

# Set the primary android and flutter root directories
ENV ANDROID_HOME="/opt/android"
ENV FLUTTER_HOME="/opt/flutter"

# Set the directory of the command line tools
ENV ANDROID_CMDLINE_TOOLS="${ANDROID_HOME}/cmdline-tools"

# Set the directory where the command line tools .zip file will be temporarily saved to.
ENV ANDROID_ARCHIVE_FILE="${ANDROID_HOME}/archive.zip"

# Add the tools to the system path
ENV PATH="${ANDROID_CMDLINE_TOOLS}/bin:${PATH}"
ENV PATH="${FLUTTER_HOME}/bin:${PATH}"

# Install the Android Command Line Tools
RUN mkdir -p "${ANDROID_HOME}"
RUN wget "${ANDROID_TOOLS_URL}" -O "${ANDROID_ARCHIVE_FILE}"
RUN unzip -d "${ANDROID_HOME}" "${ANDROID_ARCHIVE_FILE}"
RUN yes "y" | sdkmanager --sdk_root="${ANDROID_CMDLINE_TOOLS}/latest" "build-tools;31.0.0" "platforms;android-31" "platform-tools"
RUN rm "${ANDROID_ARCHIVE_FILE}"

# Get the latest stable Flutter from GitHub
RUN git clone https://github.com/flutter/flutter.git "${FLUTTER_HOME}" -b stable --depth 1

# Disable analytics and crash reporting on the builder
RUN flutter config  --no-analytics

# Perform an artifact precache so that no extra assets need to be downloaded on demand
RUN flutter precache

# Enable the Flutter development tools
RUN flutter pub global activate devtools

# Accept licenses
RUN yes "y" | flutter doctor --android-licenses

# Perform a doctor run
RUN flutter doctor -v

# Perform a flutter upgrade
RUN flutter upgrade

ENTRYPOINT [ "/bin/bash" ]
