extends Button

func _ready():
    pass

func _pressed():
    print("[GDSCRIPT] Switching to second scene...")
    if get_tree().change_scene("res://scenes/second_scene.tscn") != OK:
        print ("[GDSCRIPT] An unexpected error occured when trying to switch scenes")
    pass