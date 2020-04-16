# Sample Godot Rust App

The main purpose of this repo is to help understanding how Rust and Godot Engine work and provide a well documented project boilerplate able to display some scenes and handle signals, using properly tested Rust based logic and automatic builds via Github Actions.

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
- [Exporting](https://github.com/tommywalkie/sample-godot-rust-app#exporting)
- [Troubleshooting](https://github.com/tommywalkie/sample-godot-rust-app#troubleshooting)
- [Roadmap](https://github.com/tommywalkie/sample-godot-rust-app#roadmap)
- [License](https://github.com/tommywalkie/sample-godot-rust-app#license)

## Features

![preview](https://raw.githubusercontent.com/tommywalkie/sample-godot-rust-app/master/assets/preview_sample_godot_rust_app.png)

- Sample Godot project with two scenes
  - Each scene has a _Button_ node with a script allowing us to switch between scenes 
    - **Scene 1** ► **Scene 2** — Using GDScript ([source](https://github.com/tommywalkie/sample-godot-rust-app/blob/master/scenes/LinkToSecondScene.gd))
    - **Scene 2** ► **Scene 1** — Using Rust/GDNative ([source](https://github.com/tommywalkie/sample-godot-rust-app/blob/master/src/core/src/link_to_first_scene.rs))
  - Each scene has a node with an attached Rust/GDNative script which programmatically add a newly created colored _Panel_ node as a child node.
- Use of [Cargo workspaces](https://doc.rust-lang.org/book/ch14-03-cargo-workspaces.html) for flexibility
- Worry-free automatic cross-platform CI/CD via Github Actions

## Stack

|                                                              | Tool                                                         | Purpose                                        |
| ------------------------------------------------------------ | ------------------------------------------------------------ | ---------------------------------------------- |
| <img src="https://github.com/gilbarbara/logos/raw/master/logos/rust.svg?sanitize=true" alt="drawing" height="22" width="28"/> | Rust 1.41.1                                                  | The actual language we will use for game logic |
| <img src="https://crates.io/assets/Cargo-Logo-Small-c39abeb466d747f3be442698662c5260.png" alt="drawing" height="28" width="32"/> | [`gdnative`](https://github.com/GodotNativeTools/godot-rust) crate | For Rust bindings to Godot Engine              |
| <img src="https://crates.io/assets/Cargo-Logo-Small-c39abeb466d747f3be442698662c5260.png" alt="drawing" height="28" width="32"/> | [`speculate.rs`](https://github.com/utkarshkukreti/speculate.rs) crate | For Rust based BDD tests                       |
| <img src="https://upload.wikimedia.org/wikipedia/commons/6/6a/Godot_icon.svg" alt="drawing" height="28" width="28"/> | Godot Engine 3.2                                             | The actual game engine                         |
| <img src="https://avatars0.githubusercontent.com/u/44036562?s=200&v=4?sanitize=true" alt="drawing" height="28" width="28"/> | Github Actions                                               | For CI/CD                                      |

Under the hood, this boilerplate is using Github Actions, Docker, [`rust-embedded/cross`](https://github.com/rust-embedded/cross) and a headless Godot Engine instance to test, build and export for multiple platforms, allowing users to focus on game development while abstracting a lot of tedious tasks.

Wants to release a Godot game on Linux while working on Windows and vice-versa ? Pick this boilerplate.

## Tutorial

This tutorial is intended to re-create this boilerplate project from scratch and understand how things are connected while trying to make things clear for any newcomer in Godot / Rust without going too much into details. 

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

In order to build `gdnative` and other libraries effectively using whatever Rust toolchain, we need to install [CLang](https://rust-lang.github.io/rust-bindgen/requirements.html) which is released as part of [LLVM](https://releases.llvm.org/).

```bash
# Check if LLVM is installed and registerd in PATH
llvm-config --version
# Check if CLang is installed and registered in PATH
clang -v
```

If working on Windows, there is an additional step depending of the installed Rust toolchain. When using `stable-x86_64-pc-windows-msvc`, Visual Studio Build Tools is required. Otherwise, if using `x86_64-pc-windows-gnu`, a full GNU-compatible environment is required, this can be provided by MinGW (more details can be found on _[Working with Rust on Windows](https://github.com/rust-lang/rustup#working-with-rust-on-windows)_).

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

Remember the `.dll` , `.so` or `.dylib ` files from previous steps ? This is where we have to tell Godot how to reach them and which one to use for specific platforms. 

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



## Exporting

Assuming `gdnative` crate is cross-platform ready and we have an `export_presets.cfg` file including export related settings at the root of our project, we _can_ build `sample_godot_rust_app` in whatever target using some headless Godot Engine instances running via Github Actions and release the app for multiple platforms ([source](https://github.com/tommywalkie/sample-godot-rust-app/blob/master/.github/workflows/ci.yml)).

Here is the list of all known supported targets and possible clues about how to support other targets.

|                                                              | OS      | Supported toolchain(s)                                       |
| ------------------------------------------------------------ | ------- | ------------------------------------------------------------ |
| <img src="https://img.icons8.com/color/2x/windows-10.png" alt="drawing" height="28" width="28"/> | Windows | ✅ `stable-x86_64-pc-windows-msvc`<br />✅ `x86_64-pc-windows-gnu` |
| <img src="https://img.icons8.com/color/2x/linux.png" alt="drawing" height="35" width="34"/> | Linux   | ✅ `stable-x86_64-unknown-linux-gnu`                          |
| <img src="https://img.icons8.com/office/2x/mac-os.png" alt="drawing" height="28" width="28"/> | MacOS   | ❓ Not tested yet (See [sample-godot-rust-app#9](https://github.com/tommywalkie/sample-godot-rust-app/issues/9)) |
| <img src="https://img.icons8.com/color/2x/android-os.png" alt="drawing" height="27" width="32"/> | Android | ❓ Might be possible ([godot-rust#238](https://github.com/GodotNativeTools/godot-rust/issues/238)) |
| <img src="https://img.icons8.com/ios-filled/2x/ios-logo.png" alt="drawing" height="28" width="28"/> | iOS     | ❓ Might be possible ([godot-rust#23](https://github.com/GodotNativeTools/godot-rust/issues/238)) |

**Important notice** : We _may be_ careful when adding `export_presets.cfg` in a Git repository, especially if there is sensitive data, like keystore related settings when building for Android. This point needs to be further developed in the future.

## Troubleshooting

>  _Everything has been properly set up, but some error `error: linking with "link.exe" failed: exit code: 1104` is encountered while building libraries._

This commonly happens when editing and then re-building Rust libraries while the Godot Engine preview is still running. Stop the preview and then Cargo commands should be working fine again.

> _Cargo is correctly building `bindgen` and `clang-sys` etc. while LLVM is not in PATH. Is LLVM really needed ?_

`clang-sys` is [hardcoding LLVM paths](https://github.com/KyleMayes/clang-sys/blob/master/build/common.rs#L24) for Linux, MacOS and Windows, in case LLVM is not registered on PATH.

## Roadmap

**Setting up the project**

- [x] Init repo
- [x] Setup Rust
- [x] Add documentation for Rust related setup steps
- [x] Make a sample Rust library
- [x] Setup BDD tests, using `speculate-rs`
- [x] Setup Github Actions for CI/CD
- [x] Setup Godot Engine
- [x] Add documentation for Godot Engine related setup steps

**Rust/GDNative showcase**

- [x] Create/Interact with Godot nodes from Rust
- [ ] Send / handle signals between Rust and GDScript
- [x] Switch Godot scenes via Rust/GDScript
- [ ] Interact with assets like images via Rust/GDScript
- [ ] Make HTTP requests via Rust
- [ ] ... etc.

**Build**

- [x] Release a <img src="https://img.icons8.com/color/2x/windows-10.png" alt="drawing" height="21" width="21"/> Windows executable
- [x] Release a <img src="https://img.icons8.com/color/2x/linux.png" alt="drawing" height="23" width="25"/> Linux executable
- [ ] Release a <img src="https://img.icons8.com/office/2x/mac-os.png" alt="drawing" height="21" width="21"/> MacOS executable
- [ ] Release an <img src="https://img.icons8.com/color/2x/android-os.png" alt="drawing" height="21" width="21"/> Android application (_if possible_)
- [ ] Release an <img src="https://img.icons8.com/ios-filled/2x/ios-logo.png" alt="drawing" height="21" width="21"/> iOS application (_if possible_)

**Automatic releases**

- [x] Release a <img src="https://img.icons8.com/color/2x/windows-10.png" alt="drawing" height="21" width="21"/> Windows executable via Github Actions
- [x] Release a <img src="https://img.icons8.com/color/2x/linux.png" alt="drawing" height="23" width="25"/> Linux executable via Github Actions
- [ ] Release a <img src="https://img.icons8.com/office/2x/mac-os.png" alt="drawing" height="21" width="21"/> MacOS executable via Github Actions
- [ ] Release an <img src="https://img.icons8.com/color/2x/android-os.png" alt="drawing" height="21" width="21"/> Android application via Github Actions (_if possible_)
- [ ] Release an <img src="https://img.icons8.com/ios-filled/2x/ios-logo.png" alt="drawing" height="21" width="21"/> iOS application via Github Actions (_if possible_)

## License

MIT
