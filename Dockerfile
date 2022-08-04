#Build Stage
FROM --platform=linux/amd64 ubuntu:20.04 as builder

##Install Build Dependencies
RUN apt-get update && \
        DEBIAN_FRONTEND=noninteractive apt-get install -y python clang build-essential cmake make libjpeg-dev libopengl-dev ubuntu-restricted-extras

##ADD source code to the build stage
WORKDIR /
ADD . /jasper
WORKDIR /jasper/build

##Build
RUN ./build

FROM --platform=linux/amd64 ubuntu:20.04
RUN apt-get update && \
        DEBIAN_FRONTEND=noninteractive apt-get install -y libjpeg-turbo8
COPY --from=builder /jasper/tmp_cmake/build/src/app/jasper /jasper
COPY --from=builder /jasper/tmp_cmake/build/src/libjasper/libjasper.so.6 /usr/lib
