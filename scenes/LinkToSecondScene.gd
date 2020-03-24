extends Button

func _ready():
    pass

func _pressed():
    print("pressed")
    if get_tree().change_scene("res://scenes/second_scene.tscn") != OK:
        print ("An unexpected error occured when trying to switch scenes")
    pass