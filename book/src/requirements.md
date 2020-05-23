# Requirements

Assuming the pre-configured multi-platform continuous integration mentionned in previous part will be used, only a few tools are required :
- Github account
- Godot Engine
- Rust
- LLVM, with `llvm-config` executable 
- Apple Developer Program subscription (**only if planning to target iOS**)

## Godot Engine

Download the game engine [from the official website](https://godotengine.org/download).

**Optional** : Register the godot executable on PATH if not done yet so Godot Engine can be used via a CLI.

```bash
# Check Godot Engine version
godot --version
```

## Rust

Use [via the `rustup` tool](https://www.rust-lang.org/tools/install) to install Rust and its package manager, Cargo.

Then, check if each tool has been properly installed and registered on PATH.

```bash
# Check Rust toolchain installer version
rustup -V
# Show default Rust toolchain
rustup show
# Check Rust version
rustc --version
# Check Cargo version
cargo -V
``` 

### For Windows users

If Rust was installed via the installer, **MSVC** (`x86_64-pc-windows-msvc`) is the default Rust toolchain. MSVC requires **Visual Studio Build Tools** in order to work.


If Rust was installed via the shell script, **GNU** (`x86_64-pc-windows-gnu`) will be the default toolchain. In that case, a full GNU-compatible environment is required, this can be provided by **MinGW/MSYS2** (more details can be found on _[Working with Rust on Windows](https://github.com/rust-lang/rustup#working-with-rust-on-windows)_).


## LLVM

CLang, which is released as part of [LLVM](https://releases.llvm.org/), is required in order to compile `gdnative` and its `bindgen` crate dependency, use [the following guide](https://rust-lang.github.io/rust-bindgen/requirements.html) provided by the `bindgen` crate team.

`llvm-config` executable is also needed, check if it is registered on PATH.

```bash
# Check if llvm-config is registered
llvm-config --version
# Check CLang version
clang -v
```

`llvm-config` is usually provided by default on Windows-based LLVM installers, but can be missing in Debian-based distributions, it can be provided by the `llvm-dev` package :

```bash
# Install llvm-dev via apt-get or apt
apt-get install llvm-dev
```

## Apple Developer Program

If targetting iOS, the application must be signed with an Apple Team ID which is provided when subscribing to Apple Developer Program which costs **99 USD/yr** and requires to enable two-factor authentication (when logging for the first time), which actually **requires to register an Apple device** as a trusted device.

<br></br>

Follow the next chapter for a detailled Rust/GDNative project setup from scratch, or clone **Sample Godot Rust App** and start using it as a template and jump directly on [setting up Github Actions](setup-github-actions.md) if already knowing how to work with Rust/GDNative.