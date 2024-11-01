class_name LerpSmoothing
extends CameraControllerBase

@export var follow_speed: float = 10.0  
@export var catchup_speed: float = 30.0  
@export var leash_distance: float = 5.0  

@export var box_width: float = 5.0
@export var box_height: float = 5.0

var already_switched: bool = false

func switch_camera_2() -> void:
	if !already_switched:
		rotation_degrees.x = -90
		already_switched = true

func _process(delta: float) -> void:
	if %CameraSelector.current_controller == 2:
		switch_camera_2()
		var distance_to_target: float = position.distance_to(target.position)

		var speed: float = follow_speed
		if distance_to_target > leash_distance:
			speed = catchup_speed

		position.x = lerp(position.x, target.position.x, speed * delta)
		position.z = lerp(position.z, target.position.z, speed * delta)
		position.y = target.position.y + dist_above_target

		if draw_camera_logic:
			draw_logic()
		super(delta)

func draw_logic() -> void:
	if %CameraSelector.current_controller == 2:
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
