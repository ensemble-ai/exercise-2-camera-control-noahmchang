class_name PushBox
extends CameraControllerBase

@export var push_ratio: float = 0.8
@export var pushbox_top_left: Vector2 = Vector2(-10, 10)
@export var pushbox_bottom_right: Vector2 = Vector2(10, -10)
@export var speedup_zone_top_left: Vector2 = Vector2(-5, 5)
@export var speedup_zone_bottom_right: Vector2 = Vector2(5, -5)

var already_switched:bool = false
var frame_position:Vector3
var pushbox_width:float = pushbox_bottom_right.x - pushbox_top_left.x
var pushbox_height:float = pushbox_top_left.y - pushbox_bottom_right.y
var speedup_width:float = speedup_zone_bottom_right.x - speedup_zone_top_left.x
var speedup_height:float = speedup_zone_top_left.y - speedup_zone_bottom_right.y
var speedup:bool = false

func switch_camera_4() -> void:
	if !already_switched:
		frame_position = Vector3(%Vessel.position.x, dist_above_target, %Vessel.position.z)
		global_position = Vector3(%Vessel.position.x, dist_above_target, %Vessel.position.z)
		already_switched = true

func _process(delta: float) -> void:
	if %CameraSelector.current_controller == 4:
		switch_camera_4()
		if !current:
			return
		
		if draw_camera_logic:
			draw_logic()
		
		var tpos = target.global_position
		var cpos = global_position
		
		var diff_between_left_edges = (tpos.x - target.WIDTH / 2.0) - (cpos.x - pushbox_width / 2.0)
		if diff_between_left_edges < 0:
			speedup = false
			global_position.x += diff_between_left_edges
		var diff_between_right_edges = (tpos.x + target.WIDTH / 2.0) - (cpos.x + pushbox_width / 2.0)
		if diff_between_right_edges > 0:
			speedup = false
			global_position.x += diff_between_right_edges
		var diff_between_top_edges = (tpos.z - target.HEIGHT / 2.0) - (cpos.z - pushbox_height / 2.0)
		if diff_between_top_edges < 0:
			speedup = false
			global_position.z += diff_between_top_edges
		var diff_between_bottom_edges = (tpos.z + target.HEIGHT / 2.0) - (cpos.z + pushbox_height / 2.0)
		if diff_between_bottom_edges > 0:
			speedup = false
			global_position.z += diff_between_bottom_edges
		
		#SPEEDUP BOX
		#if speedup:
			#if target.position.x <= speedup_zone_top_left.x:
				#position.x = lerp(position.x, target.position.x, target.BASE_SPEED * push_ratio * delta)
			#elif target.position.x >= speedup_zone_bottom_right.x:
				#position.x = lerp(position.x, target.position.x, target.BASE_SPEED * push_ratio * delta)
			#if target.position.y <= speedup_zone_bottom_right.y:
				#position.y = lerp(position.y, target.position.y, target.BASE_SPEED * push_ratio * delta)
			#elif target.position.y >= speedup_zone_top_left.y:
				#position.y = lerp(position.y, target.position.y, target.BASE_SPEED * push_ratio * delta)
		
		speedup = true
		super(delta)

func draw_logic() -> void:
	if %CameraSelector.current_controller == 4:
		var mesh_instance := MeshInstance3D.new()
		var immediate_mesh := ImmediateMesh.new()
		var material := ORMMaterial3D.new()
		
		mesh_instance.mesh = immediate_mesh
		mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		
		var left:float = -pushbox_width / 2
		var right:float = pushbox_width / 2
		var top:float = -pushbox_height / 2
		var bottom:float = pushbox_height / 2
		
		immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
		immediate_mesh.surface_add_vertex(Vector3(right, 0, top))
		immediate_mesh.surface_add_vertex(Vector3(right, 0, bottom))
		
		immediate_mesh.surface_add_vertex(Vector3(right, 0, bottom))
		immediate_mesh.surface_add_vertex(Vector3(left, 0, bottom))
		
		immediate_mesh.surface_add_vertex(Vector3(left, 0, bottom))
		immediate_mesh.surface_add_vertex(Vector3(left, 0, top))
		
		immediate_mesh.surface_add_vertex(Vector3(left, 0, top))
		immediate_mesh.surface_add_vertex(Vector3(right, 0, top))
		immediate_mesh.surface_end()

		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.albedo_color = Color.WHITE
		
		# SPEEDUP BOX
		left = -speedup_width / 2
		right = speedup_width / 2
		top = -speedup_height / 2
		bottom = speedup_height / 2
		immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
		immediate_mesh.surface_add_vertex(Vector3(right, 0, top))
		immediate_mesh.surface_add_vertex(Vector3(right, 0, bottom))
		
		immediate_mesh.surface_add_vertex(Vector3(right, 0, bottom))
		immediate_mesh.surface_add_vertex(Vector3(left, 0, bottom))
		
		immediate_mesh.surface_add_vertex(Vector3(left, 0, bottom))
		immediate_mesh.surface_add_vertex(Vector3(left, 0, top))
		
		immediate_mesh.surface_add_vertex(Vector3(left, 0, top))
		immediate_mesh.surface_add_vertex(Vector3(right, 0, top))
		immediate_mesh.surface_end()

		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.albedo_color = Color.WHITE
		
		add_child(mesh_instance)
		mesh_instance.global_transform = Transform3D.IDENTITY
		mesh_instance.global_position = Vector3(global_position.x, target.global_position.y, global_position.z)
		
		await get_tree().process_frame
		mesh_instance.queue_free()
