extends MeshInstance


var time = 0
var mat
var shader

func _ready():
	pass


func _process(delta):
	if self.visible:
		mat = self.get_surface_material(0)
		shader = mat.get_shader()
		mat.set_shader_param("iTime", time)
		time += delta
