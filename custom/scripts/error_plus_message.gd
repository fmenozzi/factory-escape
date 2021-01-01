extends Reference
class_name ErrorPlusMessage

var error: int
var error_msg: String

func _init(error: int = OK, error_msg: String = '') -> void:
    self.error = error
    self.error_msg = error_msg
