# This Docker image allows us to use 'x86_64-pc-windows-gnu' toolchain
# while also installing LLVM, which is required by 'gdnative-sys' crate.

FROM rustembedded/cross:armv7-linux-androideabi

RUN apt-get -d --no-install-recommends download \
    busybox:amd64 \
    libc6:amd64 \
    libgcc1:amd64 \
    libstdc++6:amd64 \
    ncurses-base \
    zlib1g:amd64

RUN apt-get update && \
    apt-get install clang-format clang-tidy clang libc++-dev libc++1 libc++abi-dev libc++abi1 libclang-dev libclang1 libomp-dev libomp5 lldb llvm-dev llvm-runtime llvm -y

