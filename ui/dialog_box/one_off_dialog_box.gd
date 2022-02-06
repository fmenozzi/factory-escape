extends Control

signal dialog_started
signal dialog_finished

# The amount of time in seconds that passes before the next letter shows up in
# the dialog box.
const SCROLL_SPEED: float = 0.05

onready var _black_overlay: ColorRect = $BlackOverlay
onready var _label: RichTextLabel = $RichTextLabel
onready var _timer: Timer = $TextScrollTimer

func _ready() -> void:
    _timer.set_wait_time(SCROLL_SPEED)
    _timer.connect('timeout', self, '_on_timeout')

func start(dialog: String) -> void:
    _label.set_bbcode(dialog)
    _label.set_visible_characters(0)

    _set_dialog_box_visible(true)

    _timer.start()

    emit_signal('dialog_started')

func stop() -> void:
    _set_dialog_box_visible(false)
    _timer.stop()

func _set_dialog_box_visible(visible: bool) -> void:
    _black_overlay.visible = visible
    _label.visible = visible

func _on_timeout() -> void:
    _label.set_visible_characters(_label.get_visible_characters() + 1)

    if _label.get_visible_characters() >= _label.get_total_character_count():
        emit_signal('dialog_finished')
