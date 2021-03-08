extends Node2D
class_name AudioStreamPlayerVisibility

enum State {
    VISIBLE,
    ATTENUATING,
    INVISIBLE,
}

export(float, -80.0, 24.0) var volume_db := 0.0
