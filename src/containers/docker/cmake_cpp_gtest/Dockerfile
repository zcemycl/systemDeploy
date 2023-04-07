FROM ubuntu:20.04
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y
RUN apt-get install build-essential cmake libgtest-dev  -y
COPY . /tmp
WORKDIR /usr/src/googletest
RUN mkdir -p build 
WORKDIR /usr/src/googletest/build
RUN cmake .. && make && make install
WORKDIR /tmp
RUN mkdir -p build 
WORKDIR /tmp/build
RUN cmake .. && make
CMD [ "./runTests" ]
