# Flocker - Flutter in Docker

Docker image preinstalled with Flutter and the Android SDK.

[![Build](https://github.com/riaanduplessis/flutter-image/actions/workflows/build-push.yml/badge.svg)](https://github.com/riaanduplessis/flutter-image/actions/workflows/build-push.yml)

---

## Included Tools

These tools are all available in the image.

- apkanalyzer
- avdmanager
- dart
- flutter
- lint
- profgen
- retrace
- screenshot2
- sdkmanager

## Usage

Pulling the image:

```shell
docker pull ghcr.io/riaanduplessis/flocker
```

The image entrypoint is set to `/bin/bash`, so simply running the image
without any extra commands will start a shell session inside the container after startup:

```shell
docker run --rm -it ghcr.io/riaanduplessis/flocker
```

Starting a new Flutter project:

```shell
# Simply create the project with defaults set
docker run --rm ghcr.io/riaanduplessis/flocker flutter create myapp

# Create a project with specific options
docker run --rm ghcr.io/riaanduplessis/flocker flutter create --project-name myapp --org dev.flutter --android-language java --ios-language objc myapp
```

---

## License

[View license information](https://github.com/flutter/flutter/blob/master/LICENSE) for the software contained in this image.

As with all Docker images, these likely also contain other software which may be under other licenses (such as Bash, etc from the base distribution, along with any direct or indirect dependencies of the primary software being contained).

As for any pre-built image usage, it is the image user's responsibility to ensure that any use of this image complies with any relevant licenses for all software contained within.
