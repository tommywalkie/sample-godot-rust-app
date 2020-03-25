use gdnative::*;

mod first_scene;
mod second_scene;
mod link_to_first_scene;

fn init(handle: gdnative::init::InitHandle) {
    handle.add_class::<first_scene::FirstSceneNode>();
    handle.add_class::<second_scene::SecondSceneNode>();
    handle.add_class::<link_to_first_scene::LinkToFirstSceneButton>();
}

godot_gdnative_init!();
godot_nativescript_init!(init);
godot_gdnative_terminate!();