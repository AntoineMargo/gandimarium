extends Sprite2D

var mat = material as ShaderMaterial

func toggle_outline():
	if mat:
		if mat.get_shader_parameter("outline_thickness") > 0.0:
			mat.set_shader_parameter("outline_thickness", 0.0)
		else:
			mat.set_shader_parameter("outline_thickness", 1.0)
