extends Reference
class_name ErrorOr

var value
var error_plus_msg: ErrorPlusMessage

func _init(value = null, error_plus_msg := ErrorPlusMessage.new()) -> void:
    self.value = value
    self.error_plus_msg = error_plus_msg
