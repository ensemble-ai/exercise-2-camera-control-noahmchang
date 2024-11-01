class_name LerpSmoothingTarget
extends CameraControllerBase

@export var lead_speed: float = 15.0  
@export var catchup_delay_duration: float = 0.1
@export var catchup_speed: float = 20.0  
@export var leash_distance: float = 5.0  

@export var box_width: float = 5.0
@export var box_height: float = 5.0

var already_switched: bool = false
var lerp_delay_active: bool = false 
var timer_started: bool = false  

func switch_camera_2() -> void:
	if !already_switched:
		rotation_degrees.x = -90
		global_position = target.global_position
		already_switched = true

func _process(delta: float) -> void:
	if %CameraSelector.current_controller == 3:
		switch_camera_2()
		
		if draw_camera_logic:
			draw_logic()
		
		var target_velocity = target.velocity
		var distance_to_target: float = position.distance_to(target.position)

		if target_velocity == Vector3(0, 0, 0):
			if !lerp_delay_active and !timer_started:
				timer_started = true
				await get_tree().create_timer(catchup_delay_duration).timeout
				lerp_delay_active = true
				timer_started = false
		else:
			lerp_delay_active = false
		
		if lerp_delay_active:
			position.x = lerp(position.x, target.position.x, catchup_speed * delta)
			position.z = lerp(position.z, target.position.z, catchup_speed * delta)
		else:
			var speed:float
			if target_velocity.x > 0:
				position.x = lerp(position.x, target.position.x + 5, lead_speed * delta)
			elif target_velocity.x < 0:
				position.x = lerp(position.x, target.position.x - 5, lead_speed * delta)
			if target_velocity.z > 0:
				position.z = lerp(position.z, target.position.z + 5, lead_speed * delta)
			elif target_velocity.z < 0:
				position.z = lerp(position.z, target.position.z - 5, lead_speed * delta)
		position.y = target.position.y + dist_above_target
		super(delta)

func draw_logic() -> void:
	if %CameraSelector.current_controller == 3:
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
