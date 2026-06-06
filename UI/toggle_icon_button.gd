class_name ToggleIconButton extends CheckButton

@export_subgroup("Icons")
@export var toggled_icon: Texture2D
@export var untoggled_icon: Texture2D


func _ready() -> void:
    toggled.connect(_update_icon)


func _update_icon(is_toggled: bool) -> void:
    if is_toggled:
        icon = toggled_icon
    else:
        icon = untoggled_icon