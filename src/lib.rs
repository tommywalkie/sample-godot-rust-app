#[macro_use]
extern crate gdnative;

use gdnative::{Panel, GodotString, Color, StyleBoxFlat};

#[derive(gdnative::NativeClass)]
#[inherit(gdnative::Node)]
struct HelloWorld;

// [1] - Providing some game logic function that will be tested via speculate
pub fn add(a: i32, b: i32) -> i32 {
    a + b
}

#[gdnative::methods]
impl HelloWorld {
    fn _init(_owner: gdnative::Node) -> Self {
        HelloWorld
    }

    #[export]
    unsafe fn _ready(&self, mut owner: gdnative::Node) {

        // [2] - Using the imported game logic function from Godot side.
        let result: i32 = add(1,2);
        let result_string: String = format!("{}",result.to_string());
        let message = format!("{}{}", "1 + 2 = ", result_string);
        godot_print!("{}", message);

        // [3] - Trying to retrieve Godot viewport from Rust and print data in Godot.
        let viewport = &mut owner.get_viewport().unwrap();
        let size = viewport.get_size();
        godot_dbg!(size);
        godot_print!("screen width = {}", size.x);
        godot_print!("screen height = {}", size.y);

        // [4] - Retrieving node current childs count. Should be 0.
        godot_print!("Root node children = {}", owner.get_children().len());

        // [5] - Setting up some style attributes for the following Panel node.
        let blue_color = Color::rgba(0.576471, 0.313726, 0.92549, 1.0);
        let style = Some(StyleBoxFlat::new());
        style.clone().unwrap().set_bg_color(blue_color);
        let background_style: GodotString = GodotString::from_str("panel");

        // [6] - Creating a Panel node from Rust side
        let mut background = Panel::new();
        background.set_margin(2, size.x.into());
        background.set_margin(3, size.y.into());
        background.add_stylebox_override(background_style, Some(style.unwrap().to_style_box()));

        // [7] - Adding the Panel node as a child node.
        owner.add_child(Some(background.to_node()), true);

        // [8] - Retrieving node current childs count. Should be 1.
        godot_print!("Root node children = {}", owner.get_children().len());
    }
}

fn init(handle: gdnative::init::InitHandle) {
    handle.add_class::<HelloWorld>();
}

godot_gdnative_init!();
godot_nativescript_init!(init);
godot_gdnative_terminate!();