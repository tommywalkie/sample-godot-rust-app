use gdnative::*;
use fullscreen_colored_panel::generate_fullscreen_green_panel;

#[derive(NativeClass)]
#[inherit(Node)]
pub struct FirstSceneNode;

#[methods]
impl FirstSceneNode {
    pub fn _init(_owner: Node) -> Self {
        FirstSceneNode
    }

    #[export]
    pub unsafe fn _ready(&self, mut owner: Node) {
        godot_print!("I'm on the first scene !");
        let background = generate_fullscreen_green_panel(owner);
        owner.add_child(Some(background.to_node()), true);
    }
}