# This Docker image allows us to use 'x86_64-pc-windows-gnu' toolchain
# while also installing LLVM, which is required by 'gdnative-sys' crate.

FROM rustembedded/cross:armv7-linux-androideabi

RUN apt-get update && \
    apt-get install clang-format clang-tidy clang-tools clang libc++-dev libc++1 libc++abi-dev libc++abi1 libclang-dev libclang1 libomp-dev libomp5 lld lldb llvm-dev llvm-runtime llvm -y

