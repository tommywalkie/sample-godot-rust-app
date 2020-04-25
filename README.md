# Sample Godot Rust App

![CI](https://github.com/tommywalkie/sample-godot-rust-app/workflows/CI/badge.svg?branch=master)

The main purpose of this repo is to help understanding how Rust and Godot Engine work and provide a well documented project boilerplate able to display some scenes and handle signals, using properly tested Rust based logic and automatic multi-platform builds via Github Actions.

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
  - [Exporting for Android](https://github.com/tommywalkie/sample-godot-rust-app#exporting-for-android)
- [Troubleshooting](https://github.com/tommywalkie/sample-godot-rust-app#troubleshooting)
- [Roadmap](https://github.com/tommywalkie/sample-godot-rust-app#roadmap)
- [License](https://github.com/tommywalkie/sample-godot-rust-app#license)

## Features

![preview](https://raw.githubusercontent.com/tommywalkie/sample-godot-rust-app/master/assets/preview_sample_godot_rust_app.png)

- Sample Godot project with two scenes
  - Each scene has a _Button_ node with a script allowing us to switch between scenes 
    - **Scene 1** ► **Scene 2** — Using GDScript ([source](https://github.com/tommywalkie/sample-godot-rust-app/blob/master/scenes/LinkToSecondScene.gd))
    - **Scene 2** ► **Scene 1** — Using Rust/GDNative ([source](https://github.com/tommywalkie/sample-godot-rust-app/blob/master/src/core/src/link_to_first_scene.rs))
  - Each scene has a node with an attached Rust/GDNative script which programmatically add a newly created colored _Panel_ child node, acting as a full-screen background.
- Use of [Cargo workspaces](https://doc.rust-lang.org/book/ch14-03-cargo-workspaces.html) for flexibility
- Worry-free automatic multi-platform builds via Github Actions

## Stack

|                                                              | Tool                                                         | Purpose                                        |
| ------------------------------------------------------------ | ------------------------------------------------------------ | ---------------------------------------------- |
| <img src="https://github.com/gilbarbara/logos/raw/master/logos/rust.svg?sanitize=true" alt="drawing" height="22" width="28"/> | Rust 1.41.1                                                  | The actual language we will use for game logic |
| <img src="https://crates.io/assets/Cargo-Logo-Small-c39abeb466d747f3be442698662c5260.png" alt="drawing" height="28" width="32"/> | [`gdnative`](https://github.com/GodotNativeTools/godot-rust) crate | For Rust bindings to Godot Engine              |
| <img src="https://crates.io/assets/Cargo-Logo-Small-c39abeb466d747f3be442698662c5260.png" alt="drawing" height="28" width="32"/> | [`speculate.rs`](https://github.com/utkarshkukreti/speculate.rs) crate | For Rust based BDD tests                       |
| <img src="https://upload.wikimedia.org/wikipedia/commons/6/6a/Godot_icon.svg" alt="drawing" height="28" width="28"/> | Godot Engine 3.2                                             | The actual game engine                         |
| <img src="https://avatars0.githubusercontent.com/u/44036562?s=200&v=4?sanitize=true" alt="drawing" height="28" width="28"/> | Github Actions                                               | For CI/CD                                      |

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

The build result should appear in `/target/release`. We may find our Rust libraries with and `.rlib` extension and our dynamic GDNative libraries with  `.dll` (Windows), `.so` (Linux) or `.dylib ` (Mac) extension, depending of the toolchain we use.

For example, when building for Windows using a compatible toolchain like `x86_64-pc-windows-gnu`, we are expecting to find `.dll` files as output.

#### Rust to GDNative

If creating a GDNative script, like [`core`](https://github.com/tommywalkie/sample-godot-rust-app/tree/master/src/core) in this boilerplate codebase, the `lib.rs` should look like the [example one](https://github.com/GodotNativeTools/godot-rust#the-rust-source-code) in `godot-rust`.

**It is recommended to have only one Rust/GDNative library in a project**, to avoid a lot of duplicated code from `std` or somewhere else. Fortunately, it is possible to register multiple `NativeClass` at once using `add_class` method in the `init` function. In the example below, we are providing some classes like `MyClassA` and `MyClassB` to Godot.

```rust
fn init(handle: gdnative::init::InitHandle) {
    handle.add_class::<MyClassA>();
    handle.add_class::<MyClassB>();
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

Remember the `.dll` , `.so` or `.dylib ` files we generated in previous steps ? This is where we have to tell Godot how to reach them and which one to use for specific platforms. 

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

In a Godot scene file, load the `.gdnlib` library file as an external resource (`ext_resource`) with an unique identifier.

```toml
[ext_resource path="res://path/to/my_lib.gdnlib" type="GDNativeLibrary" id=1]
```

Then, create a _sub-resource_ with an unique identifier, link the newly created external resource with its `id` and pick a specific `NativeClass` among the ones we previously registered in the "[Rust to GDNative](https://github.com/tommywalkie/sample-godot-rust-app#rust-to-gdnative)" part, like `MyClassA`.

```toml
[sub_resource type="NativeScript" id=1]
resource_name = "MyClassA"
class_name = "MyClassA"
library = ExtResource( 1 )
```

Finally, attach the _sub-resource_ to a specific existing node in the scene, using its `id` :

```toml
[node name="RootNode" type="Node"]
script = SubResource( 1 )
```

Once everything is binded, we can press <kbd>F5</kbd> on keyboard or <img src="https://img.icons8.com/ios/2x/play.png" alt="drawing" height="17"/> "_Play_" button at the top-right of Godot Engine UI to run the app preview.

Here is a typical Godot scene diagram, this can be a decent summary about how things are connected.

![gdnative diagram](https://raw.githubusercontent.com/tommywalkie/sample-godot-rust-app/master/assets/godot-scene-to-gdnative-to-rust.png)

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

Under the hood, this boilerplate is using Github Actions, Docker, [`rust-embedded/cross`](https://github.com/rust-embedded/cross) and a headless Godot Engine instance to test, build and export for multiple platforms, allowing users to focus on game development while abstracting a lot of tedious tasks, using a `export_presets.cfg` file at the root of the project.

Here is the current workflow :

![workflow diagram](https://raw.githubusercontent.com/tommywalkie/sample-godot-rust-app/master/assets/github-actions-workflow.png)

Here is the list of all known supported and tested targets :

|                                                              | OS      | Supported toolchain(s)                                       |
| ------------------------------------------------------------ | ------- | ------------------------------------------------------------ |
| <img src="https://img.icons8.com/color/2x/windows-10.png" alt="drawing" height="28" width="28"/> | Windows | ✅ `stable-x86_64-pc-windows-msvc`<br />✅ `x86_64-pc-windows-gnu` |
| <img src="https://img.icons8.com/color/2x/linux.png" alt="drawing" height="35" width="34"/> | Linux   | ✅ `stable-x86_64-unknown-linux-gnu`                          |
| <img src="https://img.icons8.com/office/2x/mac-os.png" alt="drawing" height="28" width="28"/> | MacOS   | ❓ Not tested yet |
| <img src="https://img.icons8.com/color/2x/android-os.png" alt="drawing" height="27" width="32"/> | Android | ✅ `armv7-linux-androideabi`<br />✅ `aarch64-linux-android `<br />✅ `i686-linux-android `<br />✅ `x86_64-linux-android ` |
| <img src="https://img.icons8.com/ios-filled/2x/ios-logo.png" alt="drawing" height="28" width="28"/> | iOS     | ❓ Might be possible ([godot-rust#285](https://github.com/GodotNativeTools/godot-rust/issues/285)) |

The `export_presets.cfg` file keeps track of the specific export presets for each platform. For some targets, **this file may also contain sensitive data** that must be properly handled if committed into VCS. Android is one of them.

#### Exporting for Android

While the CI workflow is abstracting the Rust source compilation and the Godot Android export processes so we don't have to worry too much about how to properly setup Cargo and Android Studio, there are still some additional steps to do because of the way Android/Java is designed, like :

- Explicitly setting the Java package name (`package/unique_name`)
- Explicitly setting the screen orientation (`screen/orientation`)
- Explicitly telling which permissions we need
- Properly signing the app (unless releasing for debugging purposes)
- Explicitly telling which architectures to support (`architectures/*`)
- etc.

Permissions and most of the mentioned fields are found in `export_presets.cfg` file, under Android related presets, there should be boolean `permissions/*` fields we can edit at our convenience.

The hardest part is signing the app. If not properly handled, Play Protect might consider the APK as unsecured or worse, Godot Engine will fail to export our game. Usually, when exporting for Android, Godot Engine is requiring us to set up **JAR Signing and Verification Tool** (`jarsigner`) executable path, **Android Debug Bridge** (`adb`) executable path and a **Java keystore** path.

![](https://user-images.githubusercontent.com/16148332/79728319-0a9b5200-82ee-11ea-9c3a-dd4be1eebe35.png)

What we need to do on our side is :

- Install **Android SDK**, it usually comes up with `adb`, a debug Java keystore (`debug.keystore`), and a **JRE** which comes up with `jarsigner` and a **Java Keytool** (`keytool`)
- Register `adb` and `jarsigner` paths in _Editor > Editor Settings_ in the GUI, this also can be done while editing the `editor-settings-3.tres` file which can be located in `AppData\Roaming\Godot` (Windows) or in `~/.config/godot/` (Ubuntu)

_The following three steps are mandatory for signed releases and CI/CD._

- Make sure **GNU Privacy Guard** (`gpg`) is installed, it is usually available in most Linux distributions, otherwise, if using Windows, install it from [GnuPG Binary Releases](https://gnupg.org/download/)
- Use `keytool` to create a Java keystore and choose an alias (using `-alias` option), it will ask us some questions and to enter and confirm a password for the keystore that will be located in the relative path we set as `-keystore` option value

```bash
keytool -genkeypair -v -keystore ./my.keystore -alias some-alias -keyalg RSA -keysize 2048 -validity 10000
```

- To protect our keystore under symmetric encryption, use `gpg` to create a GPG key that also needs to be protected with another password we will be asked to enter and confirm, this will create a `.gpg` file

```bash
gpg -c .\my.keystore
```

- Finally, register the release (or debug) keystore and the alias in `export_presets.cfg` under the proper `keystore/*` fields

```
keystore/debug=""
keystore/debug_user=""
keystore/debug_password=""
keystore/release="my.keystore"
keystore/release_user="some-alias"
keystore/release_password="<SECRET-PASSWORD>"
```

As mentioned before, **it is highly recommended to not commit any keystore password into VCS**. We can just leave it as `<SECRET-PASSWORD>` and then set up a [Github secret](https://help.github.com/en/actions/configuring-and-managing-workflows/creating-and-storing-encrypted-secrets) (`$KEYSTORE_PASS`) for the keystore password so it can be passed to `export_presets.cfg` using simple `sed` commands during the CI workflow.

For our interest, when we want to decrypt `my.keystore.gpg`, we would be using the following `gpg` command without forgetting to set up `--output` option value. This means we don't need to commit `my.keystore` into VCS.

```bash
gpg --quiet --batch --yes --passphrase="$DECRYPTION_KEY" --output my.keystore my.keystore.gpg
```

This is also done during the CI workflow, so we just need to set up a second [Github secret](https://help.github.com/en/actions/configuring-and-managing-workflows/creating-and-storing-encrypted-secrets) (`$DECRYPTION_KEY`) to pass the decryption key password.

![ci workflow for android](https://raw.githubusercontent.com/tommywalkie/sample-godot-rust-app/master/assets/rust-to-android-workflow.png)

## Troubleshooting

>  _Everything has been properly set up, but some error `error: linking with "link.exe" failed: exit code: 1104` is encountered while re-building libraries._

This commonly happens when editing and then re-building Rust libraries while the Godot Engine preview is still running. Stop the preview and then Cargo commands should be working fine again.

> _Cargo is correctly building `bindgen` and `clang-sys` etc. while LLVM is not in PATH. Is LLVM really needed ?_

`clang-sys` is [hardcoding LLVM paths](https://github.com/KyleMayes/clang-sys/blob/master/build/common.rs#L24) for Linux, MacOS and Windows, in case LLVM is not registered on PATH.

> After we set up everything that is needed for Android exports, do we really need to keep Android SDK tools in our machine ?

The only purpose of the CI workflow is to abstract the Rust source compilation and Android export processes. We may still use `keytool` and `gpg` for future projects, and use `adb` and **Android Virtual Device** (AVD) for quick debugging.

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
- [x] Handle signals between Rust and GDScript
- [x] Switch Godot scenes via Rust/GDScript
- [ ] Interact with assets like images via Rust/GDScript
- [ ] Make HTTP requests via Rust
- [ ] ... etc.

**Build**

- [x] Release a <img src="https://img.icons8.com/color/2x/windows-10.png" alt="drawing" height="21" width="21"/> Windows executable
- [x] Release a <img src="https://img.icons8.com/color/2x/linux.png" alt="drawing" height="23" width="25"/> Linux executable
- [ ] Release a <img src="https://img.icons8.com/office/2x/mac-os.png" alt="drawing" height="21" width="21"/> MacOS executable
- [x] Release an <img src="https://img.icons8.com/color/2x/android-os.png" alt="drawing" height="21" width="21"/> Android application
- [ ] Release an <img src="https://img.icons8.com/ios-filled/2x/ios-logo.png" alt="drawing" height="21" width="21"/> iOS application (_if possible_)

**Automatic releases**

- [x] Release a <img src="https://img.icons8.com/color/2x/windows-10.png" alt="drawing" height="21" width="21"/> Windows executable via Github Actions
- [x] Release a <img src="https://img.icons8.com/color/2x/linux.png" alt="drawing" height="23" width="25"/> Linux executable via Github Actions
- [ ] Release a <img src="https://img.icons8.com/office/2x/mac-os.png" alt="drawing" height="21" width="21"/> MacOS executable via Github Actions
- [x] Release an <img src="https://img.icons8.com/color/2x/android-os.png" alt="drawing" height="21" width="21"/> Android application via Github Actions
- [ ] Release an <img src="https://img.icons8.com/ios-filled/2x/ios-logo.png" alt="drawing" height="21" width="21"/> iOS application via Github Actions (_if possible_)

## License

MIT
