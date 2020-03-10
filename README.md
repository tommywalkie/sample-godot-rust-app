# Sample Godot Rust App

I'm coming from a full stack JavaScript environment, my main objective here is to understand how Rust and Godot Engine work and provide a well documented Godot Engine based project boilerplate able to display some scenes and handle signals, using properly tested Rust based logic.

## Stack

|                                                              | Tool                                                         | Purpose                                        |
| ------------------------------------------------------------ | ------------------------------------------------------------ | ---------------------------------------------- |
| <img src="https://github.com/gilbarbara/logos/raw/master/logos/rust.svg?sanitize=true" alt="drawing" height="17"/> | Rust 1.41.1                                                  | The actual language we will use for game logic |
| <img src="https://img.icons8.com/dusk/2x/package.png" alt="drawing" height="17"/> | [`gdnative`](https://github.com/GodotNativeTools/godot-rust) crate | For Rust bindings to Godot Engine              |
| <img src="https://img.icons8.com/dusk/2x/package.png" alt="drawing" height="17"/> | [`speculate.rs`](https://github.com/utkarshkukreti/speculate.rs) crate | For Rust based BDD tests                       |
| <img src="https://upload.wikimedia.org/wikipedia/commons/6/6a/Godot_icon.svg" alt="drawing" height="17"/> | Godot Engine 3.2                                             | The actual game engine                         |
| <img src="https://avatars0.githubusercontent.com/u/44036562?s=200&v=4?sanitize=true" alt="drawing" height="17"/> | Github Actions                                               | For CI/CD                                      |


## Setup Rust

As far as I understand, the idea is to compile Rust scripts into libraries with proper C++ bindings which Godot Engine will be able to handle. First, we'll check if Rust is installed.

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

Then, we can setup the project workspace as it follows. The goal here is to have a `Cargo.toml` at the root then Rust source files in a `/src` folder, Rust based integration tests in a `/tests` folder and everything else related to Godot Engine and assets in any other folder(s).

```
.
├─── src
│   ├   ...
│   └   lib.rs
├─── tests
│   ├   ...
│   └   some_test_file.rs
├   ...
└   Cargo.toml
```

Setup the `Cargo.toml` file as it follows. Some of these fields will be explained later.

```toml
[package]
name = "sample_godot_rust_app" # The name of the crate

# When using "cargo build", we will need to build two crates...
[lib]
crate-type = [
	"cdylib", # One native library for C++ bindings for Godot Engine
	"lib" # One regular Rust library for integration tests
] 

[dependencies]
gdnative = "0.8" # Install Rust bindings for Godot Engine

[dev-dependencies]
speculate = "0.1" # Install and use "speculate" for integration tests only
```

Now, the whole workspace should be fine. Here are the most useful Cargo commands :

```bash
cargo build --release # Build libraries
cargo test --release # Build libraries then run integration tests
```

## Testing

Coming from a JavaScript environment where isolating business logic and integration tests (using Jest for example) in two different places was common practice, the above-mentioned settings should look familiar.

In order to properly setup integration tests, these scripts will need to access functions in source files _somehow_. The thing is Rust doesn't have the same `import` mechanic as in JavaScript. To access functions in source files, we actually need [to build a Rust library](https://github.com/rust-lang/cargo/issues/6659#issuecomment-463335095), hence why we previously added `lib` as one of the crate types in our `Cargo.toml`.

```toml
# When using "cargo build", we will need to build two crates...
[lib]
crate-type = [
	"cdylib", # One native library for C++ bindings for Godot Engine
	"lib" # One regular Rust library for integration tests
]
```

Then, in tests files, depending of how we named the project crate in `Cargo.toml`...

```toml
[package]
name = "our_crate_name" # The name of the crate
```

... We will be able to access and use crate methods, using `extern crate`. Assuming we want to test some `my_function` function available in `src/lib.rs`, here is the typical test file :

```rust
// tests/some_test_file.rs
extern crate our_crate_name;
extern crate speculate;

use speculate::speculate;
use our_crate_name::my_function;

speculate! {
    describe "sample test" {
        it "can use my_function and return true" {
            assert_eq!(my_function(), true);
        }
    }
}
```

To run the tests, use the following Cargo command :

```bash
cargo test --release
```

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

Once everything is binded, we can press <img src="https://img.icons8.com/ios-glyphs/2x/f5-key.png" alt="F5" height="22"/> "_F5_" on keyboard or <img src="https://img.icons8.com/ios/2x/play.png" alt="drawing" height="17"/> "_Play_" button at the top-right of Godot Engine UI to run the app.

## Roadmap

- [x] Init repo
- [x] Setup Rust
- [x] Add documentation for Rust related setup steps
- [x] Make a sample Rust library
- [x] Setup BDD tests, using `speculate-rs`
- [x] Setup Github Actions for CI/CD
- [x] Setup Godot Engine
- [x] Add documentation for Godot Engine related setup steps
- [ ] Make another sample Rust libraries, interacting with Godot Engine scenes
- [ ] Try releasing a Windows executable
- [ ] Try releasing an Android application