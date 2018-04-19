# Mesa3D Software Drivers
#
# VERSION 18.0.1

FROM alpine:3.7

# Build arguments.
ARG VCS_REF
ARG BUILD_DATE
ARG MESA_DEMOS="false"

# Labels / Metadata.
LABEL maintainer="James Brink, brink.james@gmail.com" \
      decription="Mesa3D Software Drivers" \
      version="18.0.1" \
      org.label-schema.name="Mesa3D-Software-Drivers" \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/jamesbrink/docker-gource" \
      org.label-schema.schema-version="1.0.0-rc1"

# Install all needed deps and compile the mesa llvmpipe driver from source.
RUN set -xe; \
    apk --update add --no-cache --virtual .runtime-deps xvfb llvm5-libs xdpyinfo; \
    apk add --no-cache --virtual .build-deps llvm-dev build-base zlib-dev glproto xorg-server-dev python-dev; \
    mkdir -p /var/tmp/build; \
    cd /var/tmp/build; \
    wget "https://mesa.freedesktop.org/archive/mesa-18.0.1.tar.gz"; \
    tar xfv mesa-18.0.1.tar.gz; \
    rm mesa-18.0.1.tar.gz; \
    cd mesa-18.0.1; \
    ./configure --enable-glx=gallium-xlib --with-gallium-drivers=swrast,swr --disable-dri --disable-gbm --disable-egl --enable-gallium-osmesa --prefix=/usr/local; \
    make; \
    make install; \
    cd .. ; \
    rm -rf mesa-18.0.1; \
    if [ "${MESA_DEMOS}" == "true" ]; then \
        apk add --no-cache --virtual .mesa-demos-runtime-deps glu glew \
        && apk add --no-cache --virtual .mesa-demos-build-deps glew-dev freeglut-dev \
        && wget "ftp://ftp.freedesktop.org/pub/mesa/demos/mesa-demos-8.4.0.tar.gz" \
        && tar xfv mesa-demos-8.4.0.tar.gz \
        && rm mesa-demos-8.4.0.tar.gz \
        && cd mesa-demos-8.4.0 \
        && ./configure --prefix=/usr/local \
        && make \
        && make install \
        && cd .. \
        && rm -rf mesa-demos-8.4.0 \
        && apk del .mesa-demos-build-deps; \
    fi; \
    apk del .build-deps;

# Copy our entrypoint into the container.
COPY ./entrypoint.sh /usr/local/bin/entrypoint.sh

# Setup our environment variables.
ENV XVFB_WHD="1920x1080x24"\
    DISPLAY=":99" \
    LIBGL_ALWAYS_SOFTWARE="1" \
    GALLIUM_DRIVER="llvmpipe" \
    LP_NO_RAST="false" \
    LP_DEBUG="" \
    LP_PERF="" \
    LP_NUM_THREADS=""

# Set the default command.
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
