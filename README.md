# Sample Godot Rust App

Just playing around Rust and Godot Engine for educational purposes, so I can understand how these tools work.

I'm coming from a full stack JavaScript environment, I'm still very new to Rust, my main objective here is to provide a Godot Engine based project boilerplate able to display some scenes and handle signals, using properly tested Rust based logic.
<br></br>

## Stack

|                                                              | Tool                 | Purpose                                                 |
| ------------------------------------------------------------ | -------------------- | ------------------------------------------------------- |
| <img src="https://github.com/gilbarbara/logos/raw/master/logos/rust.svg?sanitize=true" alt="drawing" height="17"/> | Rust                 | This is the language we will use for game logic scripts |
| <img src="https://img.icons8.com/dusk/2x/package.png" alt="drawing" height="17"/> | `gdnative` crate     | To make Rust bindings to Godot Engine                   |
| <img src="https://img.icons8.com/dusk/2x/package.png" alt="drawing" height="17"/> | `speculate-rs` crate | To make Rust based BDD tests                            |
| <img src="https://llvm.org/img/DragonMedium.png" alt="drawing" height="17"/> | CLang                | To help `rust-bindgen` make C++ bindings                |
| <img src="https://upload.wikimedia.org/wikipedia/commons/6/6a/Godot_icon.svg" alt="drawing" height="17"/> | Godot Engine 3.2     | The actual game engine                                  |
| <img src="https://avatars0.githubusercontent.com/u/44036562?s=200&v=4?sanitize=true" alt="drawing" height="17"/> | Github Actions       | For CI/CD                                               |

<br></br>

## Install

As far as I understand, the idea is to compile Rust scripts into C++ based libraries that Godot Engine will be able to handle.

First, we'll check if Rust is installed. Then depending of the OS, in order to be able to use `gdnative` crate and then compile Rust scripts into libraries with proper C++ bindings, we'll need to install [CLang](https://rust-lang.github.io/rust-bindgen/requirements.html), so `rust-bindgen` can do its job properly.

Now, the whole workspace should be fine. We can clone the project and then start building our libraries.

```bash
# Clone the project
git clone https://github.com/tommywalkie/sample-godot-rust-app.git

# Build the C++ bindings
cargo build
```
<br></br>

## Roadmap

- [x] Init repo
- [x] Setup Rust
- [x] Add documentation for Rust related setup steps
- [ ] Make a sample Rust library
- [ ] Setup BDD tests, using `speculate-rs`
- [ ] Setup Github Actions for CI/CD
- [ ] Setup Godot Engine
- [ ] Add documentation for Godot Engine related setup steps
- [ ] Make another sample Rust libraries, interacting with Godot Engine scenes
- [ ] Try releasing a Windows executable
- [ ] Try releasing an Android application