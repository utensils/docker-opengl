# Docker - Mesa 3D OpenGL Software Rendering (Gallium) - LLVMpipe, and OpenSWR Drivers

[![CircleCI](https://circleci.com/gh/utensils/docker-opengl.svg?style=svg)](https://circleci.com/gh/utensils/docker-opengl) [![Docker Automated build](https://img.shields.io/docker/automated/utensils/opengl.svg)](https://hub.docker.com/r/utensils/opengl/) [![Docker Pulls](https://img.shields.io/docker/pulls/utensils/opengl.svg)](https://hub.docker.com/r/utensils/opengl/) [![Docker Stars](https://img.shields.io/docker/stars/utensils/opengl.svg)](https://hub.docker.com/r/utensils/opengl/) [![](https://images.microbadger.com/badges/image/utensils/opengl.svg)](https://microbadger.com/images/utensils/opengl "Get your own image badge on microbadger.com") [![](https://images.microbadger.com/badges/version/utensils/opengl.svg)](https://microbadger.com/images/utensils/opengl "Get your own version badge on microbadger.com")

## About

Minimal Docker container bundled with the Mesa 3D Gallium Drivers: [LLVMpipe][mesa-llvm] & [OpenSWR][openswr], enabling OpenGL support inside a Docker container **without the need for a GPU**.

## Features

- Alpine Linux 3.12
- LLVMpipe Driver (Mesa 20.0.6)
- OpenSWR Driver (Mesa 20.0.6)
- OSMesa Interface (Mesa 20.0.6)
- softpipe - Reference Gallium software driver
- swrast - Legacy Mesa software rasterizer
- Xvfb - X Virtual Frame Buffer

## Docker Images

| Image                    | Description             | Platforms                                      | Base Image  |
| ------------------------ | ----------------------- | ---------------------------------------------- | ----------- |
| `utensils/opengl:latest` | Latest/Dev Mesa version | linux/amd64,linux/386,linux/arm64,linux/arm/v7 | alpine:3.12 |
| `utensils/opengl:stable` | Stable Mesa version     | linux/amd64,linux/386,linux/arm64,linux/arm/v7 | alpine:3.12 |
| `utensils/opengl:20.0.6` | Mesa version **20.0.6** | linux/amd64,linux/386,linux/arm64,linux/arm/v7 | alpine:3.12 |
| `utensils/opengl:19.0.8` | Mesa version **19.0.8** | linux/amd64                                    | alpine:3.10 |
| `utensils/opengl:18.3.6` | Mesa version **18.3.6** | linux/amd64                                    | alpine:3.10 |
| `utensils/opengl:18.2.8` | Mesa version **18.2.8** | linux/amd64                                    | alpine:3.10 |

## Building

This image can be built locally using the supplied `Makefile`

Make default image (stable):
```shell
make
```

Make latest image:
```shell
make latest
```

Make all images:
```shell
make all
```

## Usage

This image is intended to be used as a base image to extend from. One good example of this is the [Envisaged][Envisaged] project which allows for quick and easy Gource visualizations from within a Docker container.

Extending from this image.

```Dockerfile
FROM utensils/opengl:20.0.6
COPY ./MyAppOpenGLApp /AnywhereMyHeartDesires
RUN apk add --update my-deps...
```

## Environment Variables

The following environment variables are present to modify rendering options.

### High level settings

| Variable                | Default Value  | Description                                                    |
| ----------------------- | -------------- | -------------------------------------------------------------- |
| `XVFB_WHD`              | `1920x1080x24` | Xvfb demensions and bit depth.                                 |
| `DISPLAY`               | `:99`          | X Display number.                                              |
| `LIBGL_ALWAYS_SOFTWARE` | `1`            | Forces Mesa 3D to always use software rendering.               |
| `GALLIUM_DRIVER`        | `llvmpipe`     | Sets OpenGL Driver `llvmpipe`, `swr`, `softpipe`, and `swrast` |

### Lower level settings / tweaks

| Variable         | Default Value | Description                                                                                                                                                              |
| ---------------- | ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `LP_NO_RAST`     | `false`       | LLVMpipe - If set LLVMpipe will no-op rasterization                                                                                                                      |
| `LP_DEBUG`       | `""`          | LLVMpipe - A comma-separated list of debug options is accepted                                                                                                           |
| `LP_PERF`        | `""`          | LLVMpipe - A comma-separated list of options to selectively no-op various parts of the driver.                                                                           |
| `LP_NUM_THREADS` | `""`          | LLVMpipe - An integer indicating how many threads to use for rendering. Zero (`0`) turns off threading completely. The default value is the number of CPU cores present. |

[openswr]: http://openswr.org/
[mesa-llvm]: https://www.mesa3d.org/llvmpipe.html
[Envisaged]: https://github.com/utensils/Envisaged
