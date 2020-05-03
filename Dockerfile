# Base Docker Image
ARG BASE_IMAGE=alpine:3.11
FROM ${BASE_IMAGE} as builder

# Install all needed build deps for Mesa3D
ARG LLVM_VERSION=9
RUN set -xe; \
    apk add --no-cache \
        autoconf \
        automake \
        bison \
        build-base \
        cmake \
        elfutils-dev \
        expat-dev \
        flex \
        gettext \
        git \
        glproto \
        libtool \
        libx11-dev \
        libxrandr-dev \
        llvm${LLVM_VERSION} \
        llvm${LLVM_VERSION}-dev \
        meson \
        py-mako \
        python3-dev \
        wayland-dev \
        wayland-protocols \
        xorg-server-dev \
        zlib-dev;

# Clone Mesa source repo. (this step caches)
# Due to ongoing packaging issues we build from git vs tar packages
# Refer to https://bugs.freedesktop.org/show_bug.cgi?id=107865 
ARG MESA_VERSION
RUN set -xe; \
    mkdir -p /var/tmp/build; \
    cd /var/tmp/build/; \
    if [ "$MESA_VERSION" == "latest" ]; \
    then \
        git clone --depth=1 --branch=master https://gitlab.freedesktop.org/mesa/mesa.git; \
    else \
        git clone --depth=1 --branch=mesa-${MESA_VERSION} https://gitlab.freedesktop.org/mesa/mesa.git; \
    fi

# Build Mesa from source.
RUN set -xe; \
    cd /var/tmp/build/mesa; \
    libtoolize; \
    meson \
        --buildtype=plain \
        --prefix=/usr/local \
        -D dri-drivers= \
        -D egl=false \
        -D gallium-drivers=swrast,swr \
        -D gbm=false \
        -D glx=gallium-xlib \
        -D llvm=true \
        -D lmsensors=false \
        -D osmesa=gallium \
        -D platforms=drm,x11,wayland \
        -D shared-llvm=true \
        -D vulkan-drivers= \
        build/; \
    ninja -C build/ -j $(getconf _NPROCESSORS_ONLN); \
    ninja -C build/ install; \
    ninja -C build/ xmlpool-pot xmlpool-update-po xmlpool-gmo;

# Copy our entrypoint into the container.
COPY ./entrypoint.sh /usr/local/bin/entrypoint.sh

# Create fresh image from alpine
ARG BASE_IMAGE=alpine:3.11
FROM ${BASE_IMAGE}

# Install runtime dependencies for Mesa
ARG LLVM_VERSION=9
RUN set -xe; \
    apk --update add --no-cache \
        expat \
        llvm${LLVM_VERSION}-libs \
        xdpyinfo \
        xrandr \
        xvfb;

# Copy the Mesa build & entrypoint script from previous stage
COPY --from=builder /usr/local /usr/local

# Labels / Metadata.
ARG VCS_REF
ARG BUILD_DATE
ARG MESA_DEMOS
ARG MESA_VERSION
LABEL \
    org.opencontainers.image.authors="James Brink <brink.james@gmail.com>" \
    org.opencontainers.image.created="${BUILD_DATE}" \
    org.opencontainers.image.description="Mesa3D OpenGL Software Drivers." \
    org.opencontainers.image.revision="${VCS_REF}" \
    org.opencontainers.image.source="https://github.com/utensils/docker-opengl" \
    org.opencontainers.image.title="Mesa3D OpenGL ${MESA_VERSION}" \
    org.opencontainers.image.vendor="Utensils" \
    org.opencontainers.image.version="${MESA_VERSION}"

# Setup our environment variables.
ENV DISPLAY=":99" \
    GALLIUM_DRIVER="llvmpipe" \
    LIBGL_ALWAYS_SOFTWARE="1" \
    LP_DEBUG="" \
    LP_NO_RAST="false" \
    LP_NUM_THREADS="" \
    LP_PERF="" \
    MESA_VERSION="${MESA_VERSION}" \
    XVFB_WHD="1920x1080x24"

# Set the default command.
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
