# Sample Godot Rust App

The main purpose of this repo is to help understanding how Rust and Godot Engine work and provide a well documented Godot Engine based project boilerplate able to display some scenes and handle signals, using properly tested Rust based logic.

## Stack

|                                                              | Tool                                                         | Purpose                                        |
| ------------------------------------------------------------ | ------------------------------------------------------------ | ---------------------------------------------- |
| <img src="https://github.com/gilbarbara/logos/raw/master/logos/rust.svg?sanitize=true" alt="drawing" height="17"/> | Rust 1.41.1                                                  | The actual language we will use for game logic |
| <img src="https://img.icons8.com/dusk/2x/package.png" alt="drawing" height="17"/> | [`gdnative`](https://github.com/GodotNativeTools/godot-rust) crate | For Rust bindings to Godot Engine              |
| <img src="https://img.icons8.com/dusk/2x/package.png" alt="drawing" height="17"/> | [`speculate.rs`](https://github.com/utkarshkukreti/speculate.rs) crate | For Rust based BDD tests                       |
| <img src="https://upload.wikimedia.org/wikipedia/commons/6/6a/Godot_icon.svg" alt="drawing" height="17"/> | Godot Engine 3.2                                             | The actual game engine                         |
| <img src="https://avatars0.githubusercontent.com/u/44036562?s=200&v=4?sanitize=true" alt="drawing" height="17"/> | Github Actions                                               | For CI/CD                                      |


## Setup

### Godot

First, Godot should be installed and then when creating a new project, use any empty directory, this will be the root of the project.

After creating the Godot project, we usually end up with the following file structure, including a `project.godot` file which is the main Godot project file.

```
.
├─── .import
├   default_env.tres
├   icon.png
├   icon.png.import
└   project.godot
```

Now let's setup Rust and a Cargo workspace.

### Rust

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

Now we can start setting up the workspace. One convenient way to split Rust codebase into libraries with each their own purposes would be using [Cargo workspaces](https://doc.rust-lang.org/book/ch14-03-cargo-workspaces.html). The motivation here is to isolate Rust scripts and make them significantly smaller, more readable while still being easily testable.

We only have to put at the root of the project a primary `Cargo.toml` file and a `project.godot` file so both Cargo and Godot can work properly. Then, any Godot related resource or asset can be placed in whatever adequate folder as long as every path in the `project.godot` file is correctly set. 

The final file structure should look like this :

```
.
├─── .import
├─── assets
│   ├   icon.png
│   └   icon.png.import
├─── scenes
│   ├   my_scene.gdlib
│   └   my_scene.tscn
├─── src
├   Cargo.toml
└   project.godot
```

The primary `Cargo.toml` file should be set up as it follows. It simply tells Cargo to compile any library in `/src` folder, no need to declare each of them.

```toml
[workspace]
members = ["src/*"]
```



## Creating libraries

To create any new Rust library, we first need to tell Cargo to prepare a new library :

```bash
cargo new src/my_lib --lib
```

A new directory `my_lib` will appear in `/src` folder, with a sample `lib.rs` file and a `Cargo.toml` file.

```
.
└─── src
    └   my_lib
        ├   src
        │   └   lib.rs
        └   Cargo.toml
```

There are now **two** choices :

- _This library is intended to be used as a native script by Godot_
- _This library is intended to be used as an utility crate by Rust_

Because yes, for example it is possible to have a custom _Button_ node with an attached native script which is also internally using a custom Rust crate for math stuff.

If creating a native script, the `lib.rs` should look like the one in `godot-rust` [example](https://github.com/GodotNativeTools/godot-rust#the-rust-source-code).

The second step is telling Cargo to compile the library into a native script, there are two steps. First we need to open the `src/my_lib/Cargo.toml` file and then set the _lib.crate-type_ value as it follows.

```toml
# When using "cargo build", two crates will be created...
[lib]
crate-type = [
  "cdylib", # A Native library with C++ bindings for Godot
  "lib" # A regular Rust library for integration tests
] 
```

In the other hand, when we only want some utility Rust crate the only step is to tell Cargo to build a regular Rust library only.

```toml
[lib]
crate-type = [
  "lib"
] 
```

Now, the whole workspace should be fine. We can tell Cargo to build our libraries using this command :

```bash
cargo build --release # Build workspace libraries
```

The build result should appear in `/target/release`. We may find our `.rlib` Rust libraries with and `.rlib` extension and our GDNative libraries with  `.dll` (Windows), `.so` (Linux) or `.dylib ` (Mac) file extensions.



## Testing

Theoretically, since this project is a Cargo workspace, any testing methodology is working. To run tests for the whole workspace, use the following command :

```bash
cargo test --release
```

For demo purposes, this boilerplate project is arbitrarily using `speculate-rs` crate in the `first_scene` library, and a basic `#[cfg(test)]` Rust attribute in the `second_scene` library. When running tests from the root of the project, Cargo is smart enough to run library-specific tests no matter how they are implemented.

`speculate-rs` is a crate for testing purposes with a [Jest](https://jestjs.io/)-like syntax that should be familiar for those coming from a JavaScript environment. Here is an example :

```rust
use speculate::speculate;
use my_crate::my_function;

speculate! {
    describe "sample test" {
        it "can use my_function and return true" {
            assert_eq!(my_function(), true);
        }
    }
}
```



## Binding libraries to scenes

To bind a GDNative library to a Godot node, we first need to reference library paths in a `.gdnlib` library file so Godot can guess which file to use depending of the host OS.

```toml
[entry]

X11.64="res://target/release/my_lib.so"
OSX.64="res://target/release/my_lib.dylib"
Windows.64="res://target/release/my_lib.dll"

[dependencies]

X11.64=[  ]
OSX.64=[  ]

[general]

singleton=false
load_once=true
symbol_prefix="godot_"
reloadable=true
```

In the Godot scene file, load the `.gdnlib` library file as an external resource (`ext_resource`) with an unique identifier.

```toml
[ext_resource path="res://path/to/my_lib.gdnlib" type="GDNativeLibrary" id=1]
```

Then, create a _sub-resource_ with an unique identifier, link the newly created external resource with its `id` and tell Godot to pick a specific class returned from the actual GDNative library.

```toml
[sub_resource type="NativeScript" id=1]
resource_name = "MyCustomNode"
class_name = "MyCustomNode"
library = ExtResource( 1 )
```

Finally, attach the _sub-resource_ to a specific existing node in the scene, using its `id` :

```toml
[node name="RootNode" type="Node"]
script = SubResource( 1 )
```

Once everything is binded, we can press <kbd>F5</kbd> on keyboard or <img src="https://img.icons8.com/ios/2x/play.png" alt="drawing" height="17"/> "_Play_" button at the top-right of Godot Engine UI to run the app preview.

## Troubleshooting

>  _Everything has been properly set up, but some error `error: linking with "link.exe" failed: exit code: 1104` is encountered while building libraries._

This commonly happens when editing and then re-building Rust libraries while the Godot Engine preview is still running. Stop the preview and then Cargo commands should be working fine again.

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
- [ ] Send / handle signals between Rust and GDScript
- [x] Switch Godot scenes via Rust/GDScript
- [ ] Interact with assets like images via Rust/GDScript
- [ ] Try releasing a Windows executable
- [ ] Try releasing an Android application
- [ ] Try releasing a Windows executable via Github Actions
- [ ] Try releasing an Android application via Github Actions