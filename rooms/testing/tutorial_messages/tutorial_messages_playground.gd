extends Room

onready var _control_message_area: Area2D = $ControlMessageArea
onready var _non_control_message_area: Area2D = $NonControlMessageArea
onready var _tutorial_message_node: Control = get_node('/root/TutorialMessagesDemo/Layers/UILayer/TutorialMessage')

func _ready() -> void:
    _control_message_area.connect(
        'body_entered', self, '_on_player_entered_control_message_area')
    _control_message_area.connect(
        'body_exited', self, '_on_player_exited_control_message_area')

    _non_control_message_area.connect(
        'body_entered', self, '_on_player_entered_non_control_message_area')
    _non_control_message_area.connect(
        'body_exited', self, '_on_player_exited_non_control_message_area')

func _on_player_entered_control_message_area(player: Player) -> void:
    if not player:
        return

    _tutorial_message_node.set_control_message(Preloads.XboxA, 'Space', 'to jump')
    _tutorial_message_node.show()

func _on_player_exited_control_message_area(player: Player) -> void:
    if not player:
        return

    _tutorial_message_node.hide()

func _on_player_entered_non_control_message_area(player: Player) -> void:
    if not player:
        return

    _tutorial_message_node.set_non_control_message('Hello world!')
    _tutorial_message_node.show()

func _on_player_exited_non_control_message_area(player: Player) -> void:
    if not player:
        return

    _tutorial_message_node.hide()
