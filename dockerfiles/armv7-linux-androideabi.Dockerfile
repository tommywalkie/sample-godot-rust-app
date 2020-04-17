# This Docker image allows us to use 'x86_64-pc-windows-gnu' toolchain
# while also installing LLVM, which is required by 'gdnative-sys' crate.

FROM rustembedded/cross:armv7-linux-androideabi

RUN add-apt-repository ppa:kxstudio-team/builds

RUN ls /usr/local/bin/

RUN apt-get update && \
    apt-get install clang-format clang-tidy clang clang-tools libc++-dev libc++1 libc++abi-dev libc++abi1 libclang-dev libclang1 libomp-dev libomp5 lld lldb llvm-dev llvm-runtime llvm -y
