#!/bin/bash
#So far, only tested with mips64eb
TARGETLIST="mips64eb"
docker build -t musl_cross_builder . || exit
mkdir ./output
docker run --rm -v `realpath ./output`:/musl-cross-make/output -it -e IGLOO_TARGETLIST="$TARGETLIST" -e DOCKER_USER="$USER" \
       musl_cross_builder xonsh docker_inner_build_targets.xsh
