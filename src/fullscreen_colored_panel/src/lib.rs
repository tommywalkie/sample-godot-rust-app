use gdnative::*;

pub unsafe fn generate(owner: Node) -> Panel {
    let background: Panel = generate_blue(owner);
    (background)
}

pub unsafe fn generate_blue(owner: Node) -> Panel {
    let mut background: Panel = generate_fullscreen_panel(owner);
    let (godot_string, stylebox) = generate_style(Color::rgba(0.576471, 0.313726, 0.92549, 1.0));
    background.add_stylebox_override(godot_string, stylebox);
    (background)
}

pub unsafe fn generate_green(owner: Node) -> Panel {
    let mut background: Panel = generate_fullscreen_panel(owner);
    let (godot_string, stylebox) = generate_style(Color::rgba(0.529412, 0.937255, 0.447059, 1.0));
    background.add_stylebox_override(godot_string, stylebox);
    (background)
}

unsafe fn generate_style(color: Color) -> (GodotString, Option<StyleBox>) {
    let style = Some(StyleBoxFlat::new());
    style.clone().unwrap().set_bg_color(color);
    let background_style: GodotString = GodotString::from_str("panel");
    (background_style, Some(style.unwrap().to_style_box()))
}

unsafe fn generate_fullscreen_panel(owner: Node) -> Panel {
    let viewport = &mut owner.get_viewport().unwrap();
    let size = viewport.get_size();
    let mut background = Panel::new();
    background.set_margin(2, size.x.into());
    background.set_margin(3, size.y.into());
    (background)
}