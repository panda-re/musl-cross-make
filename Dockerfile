FROM pandare/panda:latest
RUN apt-get update && apt-get -y install build-essential xonsh git

WORKDIR /musl-cross-make
COPY . .
