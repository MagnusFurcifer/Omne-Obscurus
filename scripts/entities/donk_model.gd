extends MeshInstance

var time = 0
var mat
var shader

func _ready():
	mat = self.material_override
	shader = mat.get_shader()


func _process(delta):
	mat.set_shader_param("iTime", time)
	time += delta
