use gdnative::*;
use fullscreen_colored_panel::generate_fullscreen_blue_panel;

#[derive(NativeClass)]
#[inherit(Node)]
pub struct SecondSceneNode;

#[methods]
impl SecondSceneNode {
    pub fn _init(_owner: Node) -> Self {
        SecondSceneNode
    }

    #[export]
    pub unsafe fn _ready(&self, mut owner: Node) {
        godot_print!("I'm on the second scene !");
        let background = generate_fullscreen_blue_panel(owner);
        owner.add_child(Some(background.to_node()), true);
    }
}