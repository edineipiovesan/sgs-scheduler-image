FROM java:8-alpine

ARG GDAL_VERSION=v2.4.0
ARG LIBKML_VERSION=1.3.0

ARG BUILD_DATE=unknown
ARG TRAVIS_COMMIT=unknown

RUN \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk update && \
    apk add --virtual build-dependencies \
    # https
    openssl ca-certificates \
    build-base cmake musl-dev linux-headers \
    # pip
    py-pip \
    # proj4
    proj4 \
    # libkml dependencies
    zlib-dev minizip-dev expat-dev uriparser-dev boost-dev && \
    apk add \
    # libkml runtime
    zlib minizip expat uriparser boost && \
    update-ca-certificates && \
    mkdir /build && cd /build && \
    apk --update add tar && \
    # libkml
    wget -O libkml.tar.gz "https://github.com/libkml/libkml/archive/${LIBKML_VERSION}.tar.gz" && \
    tar --extract --file libkml.tar.gz && \
    cd libkml-${LIBKML_VERSION} && mkdir build && cd build && cmake .. && make && make install && cd ../.. && \
    # gdal
    wget -O gdal.tar.gz "https://github.com/OSGeo/gdal/archive/${GDAL_VERSION}.tar.gz" && \
    tar --extract --file gdal.tar.gz --strip-components 1 && \
    cd gdal && \
    ./configure --prefix=/usr \
        --with-libkml \
        --without-bsb \
        --without-dwgdirect \
        --without-ecw \
        --without-fme \
        --without-gnm \
        --without-grass \
        --without-grib \
        --without-hdf4 \
        --without-hdf5 \
        --without-idb \
        --without-ingress \
        --without-jasper \
        --without-mrf \
        --without-mrsid \
        --without-netcdf \
        --without-pcdisk \
        --without-pcraster \
        --without-webp \
    && make && make install && \
    # gdal python bindings
    apk add py-pip && \
    pip install gdal --no-cache-dir && \
    # fix proj4 path
    ln -s /usr/lib/libproj.so.13 /usr/lib/libproj.so && \
    # cleanup
    apk del build-dependencies && \
    cd / && \
    rm -rf build && \
    rm -rf /var/cache/apk/* && \
    rm -rf /usr/lib/python2.7

    LABEL org.label-schema.build-date=$BUILD_DATE \
          org.label-schema.name="SGS Docker image for Scheduler Application" \
          org.label-schema.description="Docker image used by SGS CI process" \
          org.label-schema.url="https://hub.docker.com/r/edineipiovesan/sgs-scheduler-image" \
          org.label-schema.vcs-ref=$TRAVIS_COMMIT \
          org.label-schema.vcs-url="https://github.com/edineipiovesan/sgs-scheduler-image" \
          org.label-schema.vendor="Edinei Piovesan" \
          org.label-schema.version=$TRAVIS_COMMIT \
          org.label-schema.schema-version="1.0"