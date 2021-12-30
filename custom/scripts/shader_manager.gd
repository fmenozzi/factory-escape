extends Node
class_name ShaderManager

var _object: Node = null

func set_object(object: Node) -> void:
    _object = object

func add_shader(shader: Shader, object: Node) -> void:
    set_object(object)

    var shader_material := ShaderMaterial.new()
    shader_material.set_shader(shader)
    _object.set_material(shader_material)

func set_shader_param(param: String, value) -> void:
    _object.get_material().set_shader_param(param, value)

func get_shader_material() -> ShaderMaterial:
    return _object.get_material()

func clear_shader() -> void:
    _object.set_material(null)
