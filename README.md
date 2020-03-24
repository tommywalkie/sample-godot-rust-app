# Sample Godot Rust App

The main objective here is to understand how Rust and Godot Engine work and provide a well documented Godot Engine based project boilerplate able to display some scenes and handle signals, using properly tested Rust based logic.

## Stack

|                                                              | Tool                                                         | Purpose                                        |
| ------------------------------------------------------------ | ------------------------------------------------------------ | ---------------------------------------------- |
| <img src="https://github.com/gilbarbara/logos/raw/master/logos/rust.svg?sanitize=true" alt="drawing" height="17"/> | Rust 1.41.1                                                  | The actual language we will use for game logic |
| <img src="https://img.icons8.com/dusk/2x/package.png" alt="drawing" height="17"/> | [`gdnative`](https://github.com/GodotNativeTools/godot-rust) crate | For Rust bindings to Godot Engine              |
| <img src="https://img.icons8.com/dusk/2x/package.png" alt="drawing" height="17"/> | [`speculate.rs`](https://github.com/utkarshkukreti/speculate.rs) crate | For Rust based BDD tests                       |
| <img src="https://upload.wikimedia.org/wikipedia/commons/6/6a/Godot_icon.svg" alt="drawing" height="17"/> | Godot Engine 3.2                                             | The actual game engine                         |
| <img src="https://avatars0.githubusercontent.com/u/44036562?s=200&v=4?sanitize=true" alt="drawing" height="17"/> | Github Actions                                               | For CI/CD                                      |


## Setup Rust

The idea is to compile Rust scripts into libraries with proper C++ bindings which Godot Engine will be able to handle. First, we'll check if Rust is installed.

```bash
# Check Rust toolchain installer version
rustup -V
# Check Rust version
rustc --version
```

Depending of the OS, in order to be able to use Rust and `gdnative` crate effectively, we'll need to install Visual Studio C++ Build tools (if using Windows) and [CLang](https://rust-lang.github.io/rust-bindgen/requirements.html).

```bash
# Check if CLang is installed and registered in PATH
clang -v
```

Now we can start setting up the workspace. One convenient way to split Rust codebase into libraries with their own purposes would be using [Cargo workspaces](https://doc.rust-lang.org/book/ch14-03-cargo-workspaces.html). The motivation here is to isolate Rust scripts and make them significantly smaller, more readable while still being easily testable.

We only have to put at the root of the project a primary `Cargo.toml` file and a `project.godot` file so both Cargo and Godot can work properly. Then, we will need a `/tests` folder for integration tests at the root of the project so the whole thing can be tested using one command, making CI/CD steps easier. Finally, any Godot related ressource or asset can be placed in whatever adequate folder as long the main scene path is referenced in `project.godot`. 

The file structure should look like :

```
.
├─── assets
├─── scenes
│   ├   my_scene.gdlib
│   └   my_scene.tscn
├─── src
│   ├   library_one
│   │   ├   src
│   │   │   └   lib.rs
│   │   └   Cargo.toml
│   ├   library_two
│   │   ├   src
│   │   │   └   lib.rs
│   │   └   Cargo.toml
├─── tests
│   └   some_test_file.rs
├   Cargo.toml
└   project.godot
```

Setup the primary `Cargo.toml` file as it follows. Some of these fields will be explained later.

```toml
[package]
name = "sample_godot_rust_app" # The name of the crate

[dependencies]
gdnative = "0.8" # Install Rust bindings for Godot Engine

[dev-dependencies]
speculate = "0.1" # Install and use "speculate" for integration tests only
```

```toml
# When using "cargo build", we will need to build two crates...
[lib]
crate-type = [
  "cdylib", # One native library for C++ bindings for Godot Engine
  "lib" # One regular Rust library for integration tests
] 
```


Now, the whole workspace should be fine. Here are the most useful Cargo commands :

```bash
cargo build --release --tests # Build workspace libraries
cargo test --release # Build workspace libraries then run integration tests
```

## Testing

When coming from a JavaScript environment where isolating business logic and integration tests (using Jest for example) in two different places was common practice, the above-mentioned settings should look familiar.

In order to properly setup integration tests, these scripts will need to access functions in source files _somehow_. The thing is Rust doesn't have the same `import` mechanic as in JavaScript. To access functions in source files, we actually need [to build a Rust library](https://github.com/rust-lang/cargo/issues/6659#issuecomment-463335095), hence why we previously added `lib` as one of the crate types in our `Cargo.toml`.

Now, depending of how we named the project crate in `Cargo.toml` we will be able to access and use crate methods in test scripts, using `extern crate`. Assuming we want to test some `my_function` function available in `src/lib.rs`, here is the typical test file :

```rust
extern crate sample_godot_rust_app; // Assuming the package.name value in Cargo.toml is "sample_godot_rust_app"
extern crate speculate;

use speculate::speculate;
use sample_godot_rust_app::my_function;

speculate! {
    describe "sample test" {
        it "can use my_function and return true" {
            assert_eq!(my_function(), true);
        }
    }
}
```

To run the tests, use the previously mention `cargo test --release` command.

Some Github Actions workflows have been set up and can be found in `/.github/workflows` folder, allowing us to automatically run tests after each push.

## Usage in Godot

After setting up Godot Engine project, in order to bind a Godot scene to a GDNative library, the scene file in question (take `Main.tscn` for example) must mention a GDNative library declaration file (let's say it is called `my_lib.gdnlib`). 

```toml
[ext_resource path="res://my_lib.gdnlib" type="GDNativeLibrary" id=1]
```

In this GDNative library declaration file, the most important fields are the GDNative library OS-specific path entries, so Godot Engine will be able to pick the correct library. When building via Cargo with `release` profile on Windows for example, Godot should expect to find a library with `.dll` extension in `target/release/` folder.

```toml
[entry]

X11.64="res://target/release/sample_godot_rust_app.so"
OSX.64="res://target/release/sample_godot_rust_app.dylib"
Windows.64="res://target/release/sample_godot_rust_app.dll"
```

Once everything is binded, we can press <kbd>F5</kbd> on keyboard or <img src="https://img.icons8.com/ios/2x/play.png" alt="drawing" height="17"/> "_Play_" button at the top-right of Godot Engine UI to run the app preview.

## Troubleshooting

- _Any Rust or `gdnative` dependency has been properly set up, but some error `error: linking with "link.exe" failed: exit code: 1104` is encountered while building libraries._

> This commonly happens when editing and then re-building Rust libraries while the Godot Engine preview is still running. Stop the preview and then Cargo commands should be working fine again.

## Roadmap

- [x] Init repo
- [x] Setup Rust
- [x] Add documentation for Rust related setup steps
- [x] Make a sample Rust library
- [x] Setup BDD tests, using `speculate-rs`
- [x] Setup Github Actions for CI/CD
- [x] Setup Godot Engine
- [x] Add documentation for Godot Engine related setup steps
- [x] Create/Interact with Godot nodes from Rust
- [x] Move to a Cargo workspace model
- [ ] Consider moving to GDScript to handle Rust methods
- [ ] Send signals via Rust and handle them via GDScript
- [ ] Switch Godot scenes via Rust/GDScript
- [ ] Interact with assets like images via Rust/GDScript
- [ ] Try releasing a Windows executable
- [ ] Try releasing an Android application
- [ ] Try releasing a Windows executable via Github Actions
- [ ] Try releasing an Android application via Github Actions