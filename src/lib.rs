#[macro_use]
extern crate gdnative;

#[derive(gdnative::NativeClass)]
#[inherit(gdnative::Node)]
struct HelloWorld;

// Some random function that will be tested in /tests after compiled into a lib
pub fn add(a: i32, b: i32) -> i32 {
    a + b
}

#[gdnative::methods]
impl HelloWorld {
    fn _init(_owner: gdnative::Node) -> Self {
        HelloWorld
    }

    #[export]
    fn _ready(&self, _owner: gdnative::Node) {
        let result: i32 = add(1,2);
        let result_string: String = format!("{}",result.to_string());
        let message = format!("{}{}", "1 + 2 = ", result_string);
        godot_print!("{}", message)
    }
}

fn init(handle: gdnative::init::InitHandle) {
    handle.add_class::<HelloWorld>();
}

godot_gdnative_init!();
godot_nativescript_init!(init);
godot_gdnative_terminate!();