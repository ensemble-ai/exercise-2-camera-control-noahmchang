class_name PositionLock
extends CameraControllerBase

@export var box_width:float = 5.0
@export var box_height:float = 5.0

func _process(delta: float) -> void:
	if %CameraSelector.current_controller == 0:
		position = target.position + Vector3(0, dist_above_target, 0)
	if draw_camera_logic:
		draw_logic()
	#%AutoScroll.frame_position = Vector3(%AutoScroll.top_left.x, 0, %AutoScroll.top_left.y)

func draw_logic() -> void:
	if %CameraSelector.current_controller == 0:
		var mesh_instance := MeshInstance3D.new()
		var immediate_mesh := ImmediateMesh.new()
		var material := ORMMaterial3D.new()
		
		mesh_instance.mesh = immediate_mesh
		mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		
		var arm_length: float = 2.5
		immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
		immediate_mesh.surface_add_vertex(Vector3(-arm_length, 0, 0))
		immediate_mesh.surface_add_vertex(Vector3(arm_length, 0, 0))
		immediate_mesh.surface_add_vertex(Vector3(0, 0, -arm_length))
		immediate_mesh.surface_add_vertex(Vector3(0, 0, arm_length))
		immediate_mesh.surface_end()

		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.albedo_color = Color.WHITE
		
		add_child(mesh_instance)
		mesh_instance.global_transform = Transform3D.IDENTITY
		mesh_instance.global_position = Vector3(global_position.x, target.global_position.y, global_position.z)
	
		await get_tree().process_frame
		mesh_instance.queue_free()
