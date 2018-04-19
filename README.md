# Docker - Mesa 3D OpenGL Software Rendering (Gallium) - LLVMpipe, and OpenSWR Drivers

[![Build Status](https://travis-ci.org/jamesbrink/docker-opengl.svg?branch=master)](https://travis-ci.org/jamesbrink/docker-opengl) [![Docker Automated build](https://img.shields.io/docker/automated/jamesbrink/opengl.svg)](https://hub.docker.com/r/jamesbrink/opengl/) [![Docker Pulls](https://img.shields.io/docker/pulls/jamesbrink/opengl.svg)](https://hub.docker.com/r/jamesbrink/opengl/) [![Docker Stars](https://img.shields.io/docker/stars/jamesbrink/opengl.svg)](https://hub.docker.com/r/jamesbrink/opengl/) [![](https://images.microbadger.com/badges/image/jamesbrink/opengl.svg)](https://microbadger.com/images/jamesbrink/opengl "Get your own image badge on microbadger.com") [![](https://images.microbadger.com/badges/version/jamesbrink/opengl.svg)](https://microbadger.com/images/jamesbrink/opengl "Get your own version badge on microbadger.com")  


## About

Minimal Docker container bundled with the Mesa 3D Gallium Drivers: [LLVMpipe][mesa-llvm] & [OpenSWR][openswr],  enabling OpenGL support inside a Docker container without the need for a GPU.


## Features

* Alpine Linux 3.7
* LLVMpipe Driver (Mesa 18.0.1)
* OpenSWR Driver (Mesa 18.0.1)
* OSMesa Interface (Mesa 18.0.1)
* softpipe - Reference Gallium software driver
* swrast - Legacy Mesa software rasterizer
* Xvfb - X Virtual Frame Buffer

## Docker Images

| Image                     | Description                                                             |
| ------------------------- | ----------------------------------------------------------------------- |
| `jamesbrink/opengl`       | Minimal image, good to extend `FROM`                                    |
| `jamesbrink/opengl:demos` | Same image with added mesa3d demos such as `glxinfo`, `glxgears`, etc.. |

## Usage

I build this image primarily to extnend from for other projects, but below are some simple examples. This image is already loaded with a trivial entrypoint script.  

Extending from this image. 

```Dockerfile
FROM jamesbrink/opengl:18.0.1
COPY ./MyAppOpenGLApp /AnywhereMyHeartDesires
RUN apk add --update my-deps...
```

Running a simple glxgears test. 

```shell
docker run jamesbrink/opengl:demos glxgears -info
```

Running glxgears with OpenSWR

```shell
docker run -e GALLIUM_DRIVER=swr jamesbrink/opengl:demos glxgears -info
```

## Environment Variables

### High level settings

| Variable                | Default Value  | Description                                                    |
| ----------------------- | -------------- | -------------------------------------------------------------- |
| `XVFB_WHD`              | `1920x1080x24` | Xvfb demensions and bit depth.                                 |
| `DISPLAY`               | `:99`          | X Display number.                                              |
| `LIBGL_ALWAYS_SOFTWARE` | `1`            | Forces Mesa 3D to always use software rendering.               |
| `GALLIUM_DRIVER`        | `llvmpipe`     | Sets OpenGL Driver `llvmpipe`, `swr`, `softpipe`, and `swrast` |

### Lower level settings / tweaks

| Variable         | Default Value | Description                                                                                                                                                   |
| ---------------- | ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `LP_NO_RAST`     | `false`       | LLVMpipe - If set LLVMpipe will no-op rasterization                                                                                                           |
| `LP_DEBUG`       | `""`          | LLVMpipe - A comma-separated list of debug options is accepted                                                                                                |
| `LP_PERF`        | `""`          | LLVMpipe - A comma-separated list of options to selectively no-op various parts of the driver.                                                                |
| `LP_NUM_THREADS` | `""`          | LLVMpipe - An integer indicating how many threads to use for rendering. Zero (`0`) turns off threading completely. The default value is the number of CPU cores present. |






[openswr]: http://openswr.org/
[mesa-llvm]: https://www.mesa3d.org/llvmpipe.html



