#!/usr/bin/env xonsh
# run inside docker guest; based on setup.sh and vsock_vpn docker_inner_build_targets.sh
import os
import re

$XONSH_TRACE_SUBPROC = True
$UPDATE_OS_ENVIRON = True
$NPROC=$(nproc).strip()

if "IGLOO_TARGETLIST" not in os.environ:
    TARGETLIST="mips64eb".split()
else:
    TARGETLIST=os.environ["IGLOO_TARGETLIST"].split()

if "DOCKER_USER" not in os.environ:
    $DOCKER_USER=$USER
    print(f"WARNING: DOCKER_USER not set, logging as built by {$USER}")

OUT="./output"

echo f"Building for {TARGETLIST} arch's"

for arch in TARGETLIST:
    if "mips" in arch:
        if arch.endswith("eb"):
            short_arch = arch[:-2]
    else:
        short_arch = arch
    OUTDIR = f"{OUT}/{short_arch}-linux-musl"
    cp f"config.mak.{arch}" config.mak
    make -j$NPROC #builds gcc/binutils
    make -j$NPROC install #actually builds musl, goes into ./output
    echo f"Built by {$DOCKER_USER} on {$(date).strip()} at version {$(git describe --all --long HEAD).strip()}" > @(OUTDIR)/README.txt
    mv @(OUTDIR) @(OUTDIR)-cross
    TARNAME=f"{short_arch}-linux-musl-cross"
    tar -C @(OUT) -czf f"{OUT}/{TARNAME}.tar.gz" @(TARNAME)
    make clean
