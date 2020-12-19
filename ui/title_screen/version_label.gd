extends Control

onready var _label: Label = $Label

func _ready() -> void:
    _label.text = Version.full()
