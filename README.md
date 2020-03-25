# Sample Godot Rust App

The main purpose of this repo is to help understanding how Rust and Godot Engine work and provide a well documented Godot Engine based project boilerplate able to display some scenes and handle signals, using properly tested Rust based logic.

![preview](https://github.com/tommywalkie/sample-godot-rust-app/tree/master/assets/preview_sample_godot_app.png)

## Summary

- [Features](https://github.com/tommywalkie/sample-godot-rust-app#features)
- [Stack](https://github.com/tommywalkie/sample-godot-rust-app#stack)
- [Tutorial](https://github.com/tommywalkie/sample-godot-rust-app#tutorial)
  - [Setup](https://github.com/tommywalkie/sample-godot-rust-app#setup)
    - [Godot](https://github.com/tommywalkie/sample-godot-rust-app#godot)
    - [Rust](https://github.com/tommywalkie/sample-godot-rust-app#rust)
  - [Creating libraries](https://github.com/tommywalkie/sample-godot-rust-app#creating-libraries)
    - [Rust to GDNative](https://github.com/tommywalkie/sample-godot-rust-app#rust-to-gdnative)
    - [Rust to Rust](https://github.com/tommywalkie/sample-godot-rust-app#rust-to-rust)
  - [Binding libraries to scenes](https://github.com/tommywalkie/sample-godot-rust-app#binding-libraries-to-scenes)
- [Testing](https://github.com/tommywalkie/sample-godot-rust-app#testing)
- [Troubleshooting](https://github.com/tommywalkie/sample-godot-rust-app#troubleshooting)
- [Roadmap](https://github.com/tommywalkie/sample-godot-rust-app#roadmap)

## Features

- Sample Godot project with two scenes
  - Each scene has a _Button_ node allowing us to switch between scenes
  - Each scene has a node with an attached Rust/GDNative script which programmatically add a newly created colored _Panel_ node as a child node.
- Use of [Cargo workspaces](https://doc.rust-lang.org/book/ch14-03-cargo-workspaces.html) for flexibility

## Stack

|                                                              | Tool                                                         | Purpose                                        |
| ------------------------------------------------------------ | ------------------------------------------------------------ | ---------------------------------------------- |
| <img src="https://github.com/gilbarbara/logos/raw/master/logos/rust.svg?sanitize=true" alt="drawing" height="17"/> | Rust 1.41.1                                                  | The actual language we will use for game logic |
| <img src="https://img.icons8.com/dusk/2x/package.png" alt="drawing" height="17"/> | [`gdnative`](https://github.com/GodotNativeTools/godot-rust) crate | For Rust bindings to Godot Engine              |
| <img src="https://img.icons8.com/dusk/2x/package.png" alt="drawing" height="17"/> | [`speculate.rs`](https://github.com/utkarshkukreti/speculate.rs) crate | For Rust based BDD tests                       |
| <img src="https://upload.wikimedia.org/wikipedia/commons/6/6a/Godot_icon.svg" alt="drawing" height="17"/> | Godot Engine 3.2                                             | The actual game engine                         |
| <img src="https://avatars0.githubusercontent.com/u/44036562?s=200&v=4?sanitize=true" alt="drawing" height="17"/> | Github Actions                                               | For CI/CD                                      |


## Tutorial

This tutorial is intended to re-create this boilerplate project from scratch and help understand how things are connected while trying to make things clear to any new guy in Godot and Rust without going too much into details. 

### Setup

We will need to install the proper tools first so we can start setting up our workspace.

#### Godot

After installing Godot, we can start creating a new project by using any empty directory, this will be the root of the project, we usually end up with the following file structure, including a `project.godot` file which is the main Godot project file.

```
.
├─── .import
├   default_env.tres
├   icon.png
├   icon.png.import
└   project.godot
```

Now let's setup a Cargo workspace.

#### Rust

The idea is to compile Rust scripts into libraries with proper C++ bindings for Godot Engine. To make things easier, we will use `rustup` so the whole Rust toolchain can be installed in a few steps, including Cargo which is the Rust package (_crate_) manager.

```bash
# Check Rust toolchain installer version
rustup -V
# Check Rust version
rustc --version
# Check Cargo version
cargo -V
```

In order to be able to use Rust and `gdnative` crate effectively, we'll also need to install Visual Studio C++ Build tools (if using Windows) and [CLang](https://rust-lang.github.io/rust-bindgen/requirements.html).

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

### Creating libraries

To create any new Rust library, we first need to tell Cargo to prepare a new library :

```bash
cargo new src/my_lib --lib
```

A new folder `/src/my_lib` will appear, with a sample `lib.rs` file and a `Cargo.toml` file.

```
src
└   my_lib
   ├   src
   │   └   lib.rs
   └   Cargo.toml
```

There are now **two** choices :

- _This library is intended to be used as a GDNative script by Godot_
- _This library is intended to be used as a crate by Rust_

For example, it is possible to have a _Button_ node with an attached custom GDNative script which is also internally using a custom Rust crate for math stuff.

When the whole workspace is set up. We can tell Cargo to build our libraries using this command :

```bash
cargo build --release # Build workspace libraries
```

The build result should appear in `/target/release`. We may find our Rust libraries with and `.rlib` extension and our GDNative libraries with  `.dll` (Windows), `.so` (Linux) or `.dylib ` (Mac) extension.

#### Rust to GDNative

If creating a GDNative script, like [`core`](https://github.com/tommywalkie/sample-godot-rust-app/tree/master/src/core) in this boilerplate codebase, the `lib.rs` should look like the [example one](https://github.com/GodotNativeTools/godot-rust#the-rust-source-code) in `godot-rust`.

It is possible to register multiple `NativeClass` at once using `add_class` method in the `init` function. So **theoretically, there should be only one GDNative library in a project**, to avoid a lot of duplicated code from `std` or other libraries, and making use of convenient features like `Instance` downcasting easier.

```rust
fn init(handle: gdnative::init::InitHandle) {
    handle.add_class::<FirstSceneNode>();
    handle.add_class::<SecondSceneNode>();
    ...
}

godot_gdnative_init!();
godot_nativescript_init!(init);
godot_gdnative_terminate!();
```

The second step is telling Cargo to compile the library into a GDNative script, open the `src/my_lib/Cargo.toml` file and then set the `lib.crate-type` value as it follows.

```toml
# When using "cargo build", two crates will be created...
[lib]
crate-type = [
  "cdylib", # A GDNative library with C++ bindings for Godot
  "lib" # A regular Rust library for integration tests
]  
```

#### Rust to Rust

In case we only want some utility Rust crate, like [`fullscreen_colored_panel`](https://github.com/tommywalkie/sample-godot-rust-app/tree/master/src/fullscreen_colored_panel) in this boilerplate codebase, the only requirement is to tell Cargo to build a regular Rust library only.

```toml
[lib]
crate-type = [
  "lib"
] 
```

Now, assuming this library is called `my_crate`, we can import it in any Cargo workspace member by using `use`.

```rust
use my_crate::*;
```

### Binding libraries to scenes

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

Then, create a _sub-resource_ with an unique identifier, link the newly created external resource with its `id` and tell Godot to pick a specific `NativeClass` registered in the actual GDNative library (read the [Rust to GDNative](https://github.com/tommywalkie/sample-godot-rust-app#rust-to-gdnative) part for explanation).

```toml
[sub_resource type="NativeScript" id=1]
resource_name = "MyCustomClass1"
class_name = "MyCustomClass1"
library = ExtResource( 1 )
```

Finally, attach the _sub-resource_ to a specific existing node in the scene, using its `id` :

```toml
[node name="RootNode" type="Node"]
script = SubResource( 1 )
```

Once everything is binded, we can press <kbd>F5</kbd> on keyboard or <img src="https://img.icons8.com/ios/2x/play.png" alt="drawing" height="17"/> "_Play_" button at the top-right of Godot Engine UI to run the app preview.



## Testing

Theoretically, since this project is a Cargo workspace, any testing methodology is fine. To run tests for the whole workspace, use the following command :

```bash
cargo test --release
```

For demo purposes, this boilerplate project is arbitrarily using `speculate-rs` crate in the [`core`](https://github.com/tommywalkie/sample-godot-rust-app/tree/master/src/core) library, and a basic `#[cfg(test)]` Rust attribute in the [`fullscreen_colored_panel`](https://github.com/tommywalkie/sample-godot-rust-app/tree/master/src/fullscreen_colored_panel) library. When running tests from the root of the project, Cargo is smart enough to run library-specific tests no matter how they are implemented.

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
- [x] Try releasing a Windows executable
- [ ] Try releasing an Android application
- [ ] Try releasing a Windows executable via Github Actions
- [ ] Try releasing an Android application via Github Actions