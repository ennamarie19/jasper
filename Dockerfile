#Build Stage
FROM --platform=linux/amd64 ubuntu:20.04 as builder

##Install Build Dependencies
RUN apt-get update && \
        DEBIAN_FRONTEND=noninteractive apt-get install -y python clang build-essential git cmake make libjpeg-dev libopengl-dev ubuntu-restricted-extras

##ADD source code to the build stage
WORKDIR /
ADD https://api.github.com/repos/ennamarie19/jasper/git/refs/heads/mayhem version.json
RUN git clone -b mayhem https://github.com/ennamarie19/jasper.git
WORKDIR /jasper/build

##Build
RUN ./build

##Prepare all library dependencies for copy
RUN mkdir /deps
RUN cp `ldd /jasper/tmp_cmake/build/src/app/jasper | grep so | sed -e '/^[^\t]/ d' | sed -e 's/\t//' | sed -e 's/.*=..//' | sed -e 's/ (0.*)//' | sort | uniq` /deps 2>/dev/null || : 

FROM --platform=linux/amd64 ubuntu:20.04
COPY --from=builder /jasper/tmp_cmake/build/src/app/jasper /jasper
COPY --from=builder /deps /usr/lib

CMD ["/jasper", "--output-format", "jpg"]
