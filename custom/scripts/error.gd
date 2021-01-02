extends Node

# This autoload only exists so that the following variables can be set anywhere
# and then read from the ErrorMessageScreen scene.

var error_code := OK
var error_message := ''

# Convenience function for setting the above variables and transitioning to the
# ErrorMessageScreen scene. Note that we pause the current tree so that no
# additional processing occurs while we make the switch. This is important
# because the switch will only happen once the scene tree is fully loaded, so
# e.g. attempts to transition during a node's _ready() function will not occur
# until it and all the remaining _ready() functions are called; the switch does
# not happen immediately. There's no need to unpause it because we'll be
# switching to a different scene tree altogether.
func report_if_error(error_plus_message: ErrorPlusMessage) -> void:
    if error_plus_message.error == OK:
        return

    error_code = error_plus_message.error
    error_message = error_plus_message.error_msg
    SceneChanger.change_scene_to(Preloads.ErrorMessageScreen, 0)
    get_tree().paused = true
