FROM ubuntu:18.04
RUN apt-get update -y
RUN apt-get install build-essential cmake libgtest-dev  -y
COPY . /tmp
WORKDIR /usr/src/gtest
RUN mkdir build 
WORKDIR /usr/src/gtest/build
RUN cmake .. && make && make install
WORKDIR /tmp
RUN mkdir build 
WORKDIR /tmp/build
RUN cmake .. && make
CMD [ "./runTests" ]
