# Base Docker Image
ARG BASE_IMAGE=alpine:3.12
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
        libdrm-dev \
        libtool \
        libva-dev \
        libx11-dev \
        libxcb-dev \
        libxdamage-dev \
        libxext-dev \
        libxfixes-dev \
        libxrandr-dev \
        libxshmfence-dev \
        libxt-dev \
        libxvmc-dev \
        libxxf86vm-dev \
        llvm${LLVM_VERSION} \
        llvm${LLVM_VERSION}-dev \
        makedepend \
        meson \
        py-mako \
        py3-libxml2 \
        py3-mako \
        python3 \
        python3-dev \
        talloc-dev \
        wayland-dev \
        wayland-protocols \
        xorg-server-dev \
        xorgproto \
        zlib-dev \
        zstd-dev;

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
ARG BUILD_TYPE=release
ARG BUILD_OPTIMIZATION=3
RUN set -xe; \
    cd /var/tmp/build/mesa; \
    libtoolize; \
    if [ "$(uname -m)" ==  "aarch64" ] || [ "$(uname -m)" == "armv7l" ]; \
    then \
        galium_drivers=swrast; \
    else \
        galium_drivers=swrast,swr; \
    fi ;\
    meson \
        --buildtype=${BUILD_TYPE} \
        --prefix=/usr/local \
        --sysconfdir=/etc \
        -D b_ndebug=true \
        -D egl=true \
        -D gallium-nine=false \
        -D gallium-xvmc=false \
        -D gbm=true \
        -D gles1=false \
        -D gles2=true \
        -D opengl=true \
        -D dri-drivers-path=/usr/local/lib/xorg/modules/dri \
        -D dri-drivers= \
        -D dri3=true  \
        -D egl=false \
        -D gallium-drivers="$galium_drivers" \
        -D gbm=false \
        -D glx=dri \
        -D llvm=true \
        -D lmsensors=false \
        -D optimization=${BUILD_OPTIMIZATION} \
        -D osmesa=gallium  \
        -D platforms=drm,x11,wayland \
        -D shared-glapi=true \
        -D shared-llvm=true \
        -D vulkan-drivers= \
        build/; \
    ninja -C build/ -j $(getconf _NPROCESSORS_ONLN); \
    ninja -C build/ install; \
    ninja -C build/ xmlpool-pot xmlpool-update-po xmlpool-gmo;

# Copy our entrypoint into the container.
COPY ./entrypoint.sh /usr/local/bin/entrypoint.sh

# Create fresh image from alpine
ARG BASE_IMAGE=alpine:3.12
FROM ${BASE_IMAGE}

# Copy the Mesa build & entrypoint script from previous stage
COPY --from=builder /usr/local /usr/local

# Install runtime dependencies for Mesa and link xorg dri modules
ARG LLVM_VERSION=9
RUN set -xe; \
    apk --update add --no-cache \
        binutils \
        expat \
        llvm${LLVM_VERSION}-libs \
        setxkbmap \
        xdpyinfo \
        xrandr \
        xvfb \
        xvfb-run \
        zstd-libs; \
    ln -sf /usr/local/lib/xorg/modules/dri/* /usr/lib/xorg/modules/dri/

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
ENV \
    DISPLAY=":99" \
    GALLIUM_DRIVER="llvmpipe" \
    LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH" \
    LIBGL_ALWAYS_SOFTWARE="1" \
    LP_DEBUG="" \
    LP_NO_RAST="false" \
    LP_NUM_THREADS="" \
    LP_PERF="" \
    MESA_VERSION="${MESA_VERSION}" \
    XVFB_WHD="1920x1080x24"

# Set the entrypoint script
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
