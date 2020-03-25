use gdnative::*;

#[derive(NativeClass)]
#[inherit(Button)]
pub struct LinkToFirstSceneButton;

#[methods]
impl LinkToFirstSceneButton {
    pub fn _init(_owner: Button) -> Self {
        LinkToFirstSceneButton
    }

    #[export]
    pub unsafe fn _ready(&self, _owner: Button) {
        
    }

    #[export]
    pub unsafe fn _pressed(&mut self, owner: Button) {
        godot_print!("[RUST] Switching to first scene...");
        let mut tree: SceneTree = owner.get_tree().unwrap();
        let first_scene_path: GodotString = GodotString::from_str("res://scenes/first_scene.tscn");
        // TODO : Look for a cleanier solution in Rust, if exists.
        let _ = tree.change_scene(first_scene_path);
    }
}