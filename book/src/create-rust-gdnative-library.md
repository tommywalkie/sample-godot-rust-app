# Create Rust/GDNative library

To create the one Rust/GDNative library that will be used by Godot, open and edit `lib.rs` file with the following content :

```rust
use gdnative::*;

// Function that registers all exposed classes to Godot
fn init(handle: gdnative::init::InitHandle) {
    
}

// macros that create the entry-points of the dynamic library.
godot_gdnative_init!();
godot_nativescript_init!(init);
godot_gdnative_terminate!();
```

This is the minimal Rust/GDNative setup. It does nothing at the moment but it is still possible to register some custom node classes in the `init` function.

Let's create a custom node class. Before the `init` function delaration, create a new class that may be called `MyClassA`. This can inherit methods from any Godot native class like `Node`, `Button`, etc.

```rust
/// The MyClassA "class"
#[derive(NativeClass)]
#[inherit(Node)]
pub struct MyClassA;
```

Then, implement the newly created `MyClassA` class and define method callbacks :

```rust
// __One__ `impl` block can have the `#[methods]` attribute, which will generate
// code to automatically bind any exported methods to Godot.
#[methods]
impl MyClassA {

    /// The "constructor" of the class.
    fn _init(_owner: Node) -> Self {
        MyClassA
    }

    #[export]
    fn _ready(&self, _owner: Node) {
        godot_print!("Hello world from MyClassA.");
    }
}
```

Finally register the new class in the `init` function.

```diff
fn init(handle: gdnative::init::InitHandle) {
+    handle.add_class::<MyClassA>();
}
```

This can be repeated, since it is possible to register multiple classes at once. The final file content should look like this :

```rust
use gdnative::*;

#[derive(NativeClass)]
#[inherit(Node)]
pub struct MyClassA;

#[derive(NativeClass)]
#[inherit(Node)]
pub struct MyClassB;

#[methods]
impl MyClassA {
    fn _init(_owner: Node) -> Self {
        MyClassA
    }
    #[export]
    fn _ready(&self, _owner: Node) {
        godot_print!("Hello world from MyClassA.");
    }
}

#[methods]
impl MyClassB {
    fn _init(_owner: Node) -> Self {
        MyClassB
    }
    #[export]
    fn _ready(&self, _owner: Node) {
        godot_print!("Hello world from MyClassB.");
    }
}

fn init(handle: gdnative::init::InitHandle) {
    handle.add_class::<MyClassA>();
    handle.add_class::<MyClassB>();
}

godot_gdnative_init!();
godot_nativescript_init!(init);
godot_gdnative_terminate!();
```

Finally, build the Rust/GDNative library with Cargo.

```bash
cargo build --release
```

The build result should appear in `/target/release`. Depending of the active Rust toolchain and the settings on Cargo configuration files, there will be Rust libraries (`*.rlib`) and/or dynamic libraries (`*.dll` on Windows, `*.so` on Linux, or `*.dylib` on Mac).

The next part will be about making Godot aware of the newly generated Rust/GDNative libraries.