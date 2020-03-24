use gdnative::*;
use fullscreen_colored_panel::generate_green as generate_fullscreen_green_panel;

#[derive(NativeClass)]
#[inherit(Node)]
struct SceneNode;

pub mod math;

#[methods]
impl SceneNode {
    pub fn _init(_owner: Node) -> Self {
        SceneNode
    }

    #[export]
    pub unsafe fn _ready(&self, mut owner: Node) {
        godot_print!("I'm on the first scene !");
        let result: i32 = math::add(1,2);
        let result_string: String = format!("{}",result.to_string());
        let message = format!("{}{}", "1 + 2 = ", result_string);
        godot_print!("{}", message);
        let background = generate_fullscreen_green_panel(owner);
        owner.add_child(Some(background.to_node()), true);
    }
}

fn init(handle: gdnative::init::InitHandle) {
    handle.add_class::<SceneNode>();
}

godot_gdnative_init!();
godot_nativescript_init!(init);
godot_gdnative_terminate!();