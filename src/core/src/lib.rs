use gdnative::*;

mod first_scene;
mod second_scene;

fn init(handle: gdnative::init::InitHandle) {
    handle.add_class::<first_scene::FirstSceneNode>();
    handle.add_class::<second_scene::SecondSceneNode>();
}

godot_gdnative_init!();
godot_nativescript_init!(init);
godot_gdnative_terminate!();