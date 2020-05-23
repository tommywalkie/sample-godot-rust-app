# Setup Godot project

Open Godot Engine and start creating a new project by using any empty directory, the current file structure should now contain a `project.godot` file which is the main Godot project file.

```
.
├─── .import
├   default_env.tres
├   icon.png
├   icon.png.import
└   project.godot
```

Open and edit the `.gitignore` file and add `.import` directory and assets with `*.import` file extension, these are just some Godot Engine generated cache files, no need to commit them.

```bash
# Godot Engine assets cache
.import/
*.import
```

Create a first Godot scene via the editor, this should create a `.tscn` scene file with this content :

```
[gd_scene load_steps=4 format=2]
```

Make sure it is recognized by Godot Engine as the entrypoint, by editing the `run/main_scene` field value on the `project.godot` file. Note `res://` is the project root path.

```
[application]
run/main_scene="res://path/to/my/scene.tscn"
```

Godot scenes can contain nodes, and properties and can have attached scripts. Scripts can be written in GDScript (`.gd`) or can be GDNative libraries (`.gdnlib`). Follow the next chapter to learn to create a Rust/GDNative library.