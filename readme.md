# Flutter image for docker

![Build](https://github.com/riaanduplessis/flutter-image/workflows/CI/badge.svg?branch=master)

This image automatically installs and sets up the Flutter SDK and android SDK.

## Pull image

```
docker pull riaanduplessis/flutter:latest
```

## Persisted build arguments

You can pass these values for these variables when building the image to change the android SDK versioning as required.

| NAME            | Default    |
|-----------------|:----------:|
| build_tools_ver | 29.0.2     |
| patcher_ver     | v4         |
| platforms       | android-29 |
| sources         | android-29 |

### Building image with custom arguments

Below is an example of building the image with SDK tools for API level 28
```
docker build --build-arg platforms=android-28 --build-arg sources=android-28 .
```