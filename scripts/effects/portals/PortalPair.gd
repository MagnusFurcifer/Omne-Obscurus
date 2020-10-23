extends Spatial

onready var portals := [$PortalA, $PortalB]
onready var links := {
	$PortalA: $PortalB,
	$PortalB: $PortalA,
}

var portals_active = true


func init_portal(portal: Node) -> void:
	# Connect the mesh material shader to the viewport of the linked portal
	var linked: Node = links[portal]
	var link_viewport: Viewport = linked.get_node("Viewport")
	var tex := link_viewport.get_texture()
	var mat = portal.get_node("MeshInstance").material_override
	mat.set_shader_param("texture_albedo", tex)


# Init portals
func _ready() -> void:
	for portal in portals:
		init_portal(portal)


func get_camera() -> Camera:
	if Engine.is_editor_hint():
		return get_node("/root/EditorCameraProvider").get_camera()
	else:
		return get_viewport().get_camera()


# Move the camera to a location near the linked portal; this is done by
# taking the position of the player relative to the linked portal, and
# rotating it pi radians
func move_camera(portal: Node) -> void:
	var linked: Node = links[portal]
	var trans: Transform = linked.global_transform.inverse() \
			* get_camera().global_transform
	var up := Vector3(0, 1, 0)
	trans = trans.rotated(up, PI)
	portal.get_node("CameraHolder").transform = trans
	var cam_pos: Transform = portal.get_node("CameraHolder").global_transform
	portal.get_node("Viewport/Camera").global_transform = cam_pos


# Sync the viewport size with the window size
func sync_viewport(portal: Node) -> void:
	portal.get_node("Viewport").size = get_viewport().size


# warning-ignore:unused_argument
func _process(delta: float) -> void:
	if portals_active:
		if Engine.is_editor_hint():
			if get_camera() == null:
				return
			_ready()

		for portal in portals:
			move_camera(portal)
			sync_viewport(portal)

func enter_portal(portal: Spatial, body: PhysicsBody) -> void:
	if body.is_in_group("portal_bois"):
		if portal == $PortalA:
			body.global_transform.origin = $PortalB/portal_spawn.global_transform.origin
			Globals.playernode.hide_ui()
			for obj in get_tree().get_nodes_in_group("portal_hidden_walls"):
				obj.visible = true
				portals_active = false
			for obj in get_tree().get_nodes_in_group("giprobes"):
				#obj.bake()
				pass
			$PortalB.queue_free()
			for obj in get_tree().get_nodes_in_group("area_01"):
				obj.queue_free()
			for obj in get_tree().get_nodes_in_group("area_02_outside_lights"):
				obj.visible = false
			for obj in get_tree().get_nodes_in_group("area_02_entry_lights"):
				obj.visible = true
			for obj in get_tree().get_nodes_in_group("area_01_sounds"):
				obj.playing = false
			Globals.playernode.switch_lantern_range()

func _physics_process(delta: float) -> void:
	if portals_active:
		# Don't handle physics while in the editor
		if Engine.is_editor_hint():
			return

		# Check for bodies overlapping portals
		for portal in portals:
			for body in portal.get_node("Area").get_overlapping_bodies():
				enter_portal(portal, body)
