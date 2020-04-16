FROM rustembedded/cross:x86_64-pc-windows-gnu

RUN apt-get update && \
    apt-get install clang-format clang-tidy clang-tools clang libc++-dev libc++1 libc++abi-dev libc++abi1 libclang-dev libclang1 libomp-dev libomp5 lld lldb llvm-dev llvm-runtime llvm -y

